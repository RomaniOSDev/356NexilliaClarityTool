import Foundation
import Combine

final class PlanEditorViewModel: ObservableObject {
    @Published var title: String
    @Published var descriptionText: String
    @Published var tagsText: String
    @Published var reminderDate: Date
    @Published var needsRevision: Bool
    @Published var subject: Subject
    @Published var linkedLessonId: UUID?

    private let existingId: UUID?
    private let isArchived: Bool
    let isEditing: Bool

    init(plan: LessonPlan?) {
        if let plan {
            existingId = plan.id
            title = plan.title
            descriptionText = plan.description
            tagsText = TagParser.joined(plan.tags)
            reminderDate = plan.reminderDate
            needsRevision = plan.needsRevision
            subject = plan.subject
            linkedLessonId = plan.linkedLessonId
            isArchived = plan.isArchived
            isEditing = true
        } else {
            existingId = nil
            title = ""
            descriptionText = ""
            tagsText = ""
            reminderDate = Date()
            needsRevision = false
            subject = .math
            linkedLessonId = nil
            isArchived = false
            isEditing = false
        }
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func applyLinkedLesson(_ lesson: TaggedLesson?) {
        if let lesson {
            linkedLessonId = lesson.id
            subject = lesson.subject
        } else {
            linkedLessonId = nil
        }
    }

    func applyTemplate(_ template: PlanTemplate) {
        let block = template.fill
        if descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            descriptionText = block
        } else if !descriptionText.contains(block) {
            descriptionText += "\n\n" + block
        }
    }

    func commit(to store: DataStore) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let linked = linkedLessonId, let lesson = store.lesson(id: linked) {
            subject = lesson.subject
        }
        let plan = LessonPlan(
            id: existingId ?? UUID(),
            title: trimmed,
            description: descriptionText.trimmingCharacters(in: .whitespacesAndNewlines),
            tags: TagParser.parse(tagsText),
            reminderDate: reminderDate,
            needsRevision: needsRevision,
            subject: subject,
            linkedLessonId: linkedLessonId,
            isArchived: isArchived
        )
        store.upsertPlan(plan)
    }
}
