import Foundation
import Combine

final class StatsViewModel: ObservableObject {
    struct SubjectMix: Identifiable {
        var id: String { "\(subject.rawValue)-\(kind)" }
        let subject: Subject
        let kind: String
        let count: Int
    }

    struct ActivityPoint: Identifiable {
        var id: String { "\(kind)-\(day.timeIntervalSince1970)" }
        let day: Date
        let kind: String
        let count: Int
    }

    struct KindShare: Identifiable {
        var id: String { kind }
        let kind: String
        let count: Int
    }

    struct TagCount: Identifiable {
        var id: String { tag }
        let tag: String
        let count: Int
    }

    @Published private(set) var lessonCount = 0
    @Published private(set) var snapCount = 0
    @Published private(set) var planCount = 0
    @Published private(set) var revisionCount = 0
    @Published private(set) var linkedSnapCount = 0
    @Published private(set) var subjectMix: [SubjectMix] = []
    @Published private(set) var activity: [ActivityPoint] = []
    @Published private(set) var kindShare: [KindShare] = []
    @Published private(set) var upcoming: [LessonPlan] = []
    @Published private(set) var topTags: [TagCount] = []

    var grandTotal: Int { lessonCount + snapCount + planCount }
    var hasData: Bool { grandTotal > 0 }

    func rebuild(from store: DataStore) {
        lessonCount = store.activeLessons.count
        snapCount = store.activeSnaps.count
        planCount = store.activePlans.count
        revisionCount = store.revisionCount
        linkedSnapCount = store.activeSnaps.filter { $0.linkedLessonId != nil }.count

        var mix: [SubjectMix] = []
        for subject in Subject.allCases {
            mix.append(SubjectMix(subject: subject, kind: "Lessons", count: store.activeLessons.filter { $0.subject == subject }.count))
            mix.append(SubjectMix(subject: subject, kind: "Snaps", count: store.activeSnaps.filter { store.resolvedSubject(for: $0) == subject }.count))
            mix.append(SubjectMix(subject: subject, kind: "Plans", count: store.activePlans.filter { store.resolvedSubject(for: $0) == subject }.count))
        }
        subjectMix = mix

        kindShare = [
            KindShare(kind: "Lessons", count: lessonCount),
            KindShare(kind: "Snaps", count: snapCount),
            KindShare(kind: "Plans", count: planCount)
        ].filter { $0.count > 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var points: [ActivityPoint] = []
        for offset in (0..<14).reversed() {
            let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            let next = calendar.date(byAdding: .day, value: 1, to: day) ?? day
            let lessons = store.activeLessons.filter { $0.revisedDate >= day && $0.revisedDate < next }.count
            let snaps = store.activeSnaps.filter { $0.lastEdited >= day && $0.lastEdited < next }.count
            points.append(ActivityPoint(day: day, kind: "Lessons", count: lessons))
            points.append(ActivityPoint(day: day, kind: "Snaps", count: snaps))
        }
        activity = points

        let futurePlans = store.activePlans
            .filter { $0.reminderDate >= today }
            .sorted { $0.reminderDate < $1.reminderDate }
        upcoming = Array(futurePlans.prefix(6))

        var tagHits: [String: Int] = [:]
        let allTags = store.activeLessons.flatMap(\.tags) + store.activeSnaps.flatMap(\.tags) + store.activePlans.flatMap(\.tags)
        for tag in allTags {
            tagHits[tag, default: 0] += 1
        }
        let ranked = tagHits.map { TagCount(tag: $0.key, count: $0.value) }
            .sorted { lhs, rhs in
                if lhs.count == rhs.count { return lhs.tag < rhs.tag }
                return lhs.count > rhs.count
            }
        topTags = Array(ranked.prefix(8))
    }
}
