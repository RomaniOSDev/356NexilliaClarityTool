import Foundation
import Combine

final class DataStore: ObservableObject {
    enum UndoPayload {
        case lesson(TaggedLesson)
        case snap(LessonSnap)
        case plan(LessonPlan)
    }

    @Published var lessons: [TaggedLesson] = []
    @Published var snaps: [LessonSnap] = []
    @Published var plans: [LessonPlan] = []
    @Published private(set) var undoPayload: UndoPayload?
    @Published private(set) var undoMessage = ""
    @Published private(set) var undoToken = UUID()

    private let lessonsKey = "planner.lessons.json"
    private let snapsKey = "planner.snaps.json"
    private let plansKey = "planner.plans.json"
    private let defaults: UserDefaults

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadAll()
        ReminderScheduler.resync(plans)
    }

    var activeLessons: [TaggedLesson] {
        lessons.filter { !$0.isArchived }
    }

    var archivedLessons: [TaggedLesson] {
        lessons.filter(\.isArchived)
    }

    var lessonsByDate: [TaggedLesson] {
        activeLessons.sorted { $0.revisedDate > $1.revisedDate }
    }

    var activeSnaps: [LessonSnap] {
        snaps.filter { !$0.isArchived }
    }

    var archivedSnaps: [LessonSnap] {
        snaps.filter(\.isArchived)
    }

    var snapsByEdit: [LessonSnap] {
        activeSnaps.sorted { $0.lastEdited > $1.lastEdited }
    }

    var activePlans: [LessonPlan] {
        plans.filter { !$0.isArchived }
    }

    var archivedPlans: [LessonPlan] {
        plans.filter(\.isArchived)
    }

    var plansByReminder: [LessonPlan] {
        activePlans.sorted { $0.reminderDate < $1.reminderDate }
    }

    var revisionCount: Int {
        activePlans.filter(\.needsRevision).count
    }

    var archivedCount: Int {
        archivedLessons.count + archivedSnaps.count + archivedPlans.count
    }

    func lesson(id: UUID) -> TaggedLesson? {
        lessons.first { $0.id == id }
    }

    func resolvedSubject(for snap: LessonSnap) -> Subject {
        if let linked = snap.linkedLessonId, let lesson = lesson(id: linked) {
            return lesson.subject
        }
        return snap.subject
    }

    func resolvedSubject(for plan: LessonPlan) -> Subject {
        if let linked = plan.linkedLessonId, let lesson = lesson(id: linked) {
            return lesson.subject
        }
        return plan.subject
    }

    func upsertLesson(_ lesson: TaggedLesson) {
        if let index = lessons.firstIndex(where: { $0.id == lesson.id }) {
            lessons[index] = lesson
        } else {
            lessons.append(lesson)
        }
        persistLessons()
    }

    func archiveLesson(_ lesson: TaggedLesson) {
        var archived = lesson
        archived.isArchived = true
        rememberUndo(.lesson(lesson), message: "Lesson archived")
        upsertLesson(archived)
    }

    func restoreLesson(_ lesson: TaggedLesson) {
        var restored = lesson
        restored.isArchived = false
        upsertLesson(restored)
    }

    func deleteLesson(_ lesson: TaggedLesson) {
        rememberUndo(.lesson(lesson), message: "Lesson deleted")
        lessons.removeAll { $0.id == lesson.id }
        clearLinks(to: lesson.id)
        persistLessons()
        persistSnaps()
        persistPlans()
    }

    func upsertSnap(_ snap: LessonSnap) {
        if let index = snaps.firstIndex(where: { $0.id == snap.id }) {
            snaps[index] = snap
        } else {
            snaps.append(snap)
        }
        persistSnaps()
    }

    func archiveSnap(_ snap: LessonSnap) {
        var archived = snap
        archived.isArchived = true
        rememberUndo(.snap(snap), message: "Snap archived")
        upsertSnap(archived)
    }

    func restoreSnap(_ snap: LessonSnap) {
        var restored = snap
        restored.isArchived = false
        upsertSnap(restored)
    }

    func deleteSnap(_ snap: LessonSnap) {
        rememberUndo(.snap(snap), message: "Snap deleted")
        snaps.removeAll { $0.id == snap.id }
        persistSnaps()
    }

    func upsertPlan(_ plan: LessonPlan) {
        var stored = plan
        if let linked = stored.linkedLessonId, let lesson = lesson(id: linked) {
            stored.subject = lesson.subject
        }
        if let index = plans.firstIndex(where: { $0.id == stored.id }) {
            plans[index] = stored
        } else {
            plans.append(stored)
        }
        persistPlans()
        ReminderScheduler.sync(stored)
    }

    func archivePlan(_ plan: LessonPlan) {
        var archived = plan
        archived.isArchived = true
        rememberUndo(.plan(plan), message: "Plan archived")
        upsertPlan(archived)
    }

    func restorePlan(_ plan: LessonPlan) {
        var restored = plan
        restored.isArchived = false
        upsertPlan(restored)
    }

    func deletePlan(_ plan: LessonPlan) {
        rememberUndo(.plan(plan), message: "Plan deleted")
        plans.removeAll { $0.id == plan.id }
        persistPlans()
        ReminderScheduler.cancel(plan.id)
    }

    func duplicateLesson(_ lesson: TaggedLesson) {
        upsertLesson(
            TaggedLesson(
                title: "\(lesson.title) (copy)",
                subject: lesson.subject,
                tags: lesson.tags,
                revisedDate: Date(),
                periodLabel: lesson.periodLabel,
                durationMinutes: lesson.durationMinutes
            )
        )
    }

    func duplicateSnap(_ snap: LessonSnap) {
        upsertSnap(
            LessonSnap(
                title: "\(snap.title) (copy)",
                note: snap.note,
                tags: snap.tags,
                lastEdited: Date(),
                linkedLessonId: snap.linkedLessonId,
                subject: snap.subject
            )
        )
    }

    func duplicatePlan(_ plan: LessonPlan) {
        upsertPlan(
            LessonPlan(
                title: "\(plan.title) (copy)",
                description: plan.description,
                tags: plan.tags,
                reminderDate: plan.reminderDate,
                needsRevision: plan.needsRevision,
                subject: plan.subject,
                linkedLessonId: plan.linkedLessonId
            )
        )
    }

    func randomSnap() -> LessonSnap? {
        activeSnaps.randomElement()
    }

    func undoLast() {
        guard let undoPayload else { return }
        switch undoPayload {
        case .lesson(let lesson):
            upsertLesson(lesson)
            persistSnaps()
            persistPlans()
        case .snap(let snap):
            upsertSnap(snap)
        case .plan(let plan):
            upsertPlan(plan)
        }
        clearUndo()
    }

    func clearUndo() {
        undoPayload = nil
        undoMessage = ""
    }

    func resetAll() {
        lessons = []
        snaps = []
        plans = []
        clearUndo()
        defaults.removeObject(forKey: lessonsKey)
        defaults.removeObject(forKey: snapsKey)
        defaults.removeObject(forKey: plansKey)
        ReminderScheduler.cancelAll()
        NotificationCenter.default.post(name: AppNotifications.dataDidReset, object: nil)
    }

    private func rememberUndo(_ payload: UndoPayload, message: String) {
        undoPayload = payload
        undoMessage = message
        undoToken = UUID()
    }

    private func clearLinks(to lessonId: UUID) {
        for index in snaps.indices where snaps[index].linkedLessonId == lessonId {
            snaps[index].linkedLessonId = nil
        }
        for index in plans.indices where plans[index].linkedLessonId == lessonId {
            plans[index].linkedLessonId = nil
        }
    }

    private func loadAll() {
        lessons = decode([TaggedLesson].self, key: lessonsKey) ?? []
        snaps = decode([LessonSnap].self, key: snapsKey) ?? []
        plans = decode([LessonPlan].self, key: plansKey) ?? []
    }

    private func persistLessons() {
        encode(lessons, key: lessonsKey)
    }

    private func persistSnaps() {
        encode(snaps, key: snapsKey)
    }

    private func persistPlans() {
        encode(plans, key: plansKey)
    }

    private func encode<T: Encodable>(_ value: T, key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }
}
