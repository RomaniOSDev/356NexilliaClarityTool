import Foundation
import Combine

final class LessonEditorViewModel: ObservableObject {
    @Published var title: String
    @Published var subject: Subject
    @Published var tagsText: String
    @Published var periodLabel: String
    @Published var durationMinutes: Int

    private let existingId: UUID?
    private let isArchived: Bool
    let isEditing: Bool

    init(lesson: TaggedLesson?) {
        if let lesson {
            existingId = lesson.id
            title = lesson.title
            subject = lesson.subject
            tagsText = TagParser.joined(lesson.tags)
            periodLabel = lesson.periodLabel
            durationMinutes = lesson.durationMinutes
            isArchived = lesson.isArchived
            isEditing = true
        } else {
            existingId = nil
            title = ""
            subject = .math
            tagsText = ""
            periodLabel = ""
            durationMinutes = 45
            isArchived = false
            isEditing = false
        }
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func commit(to store: DataStore) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let lesson = TaggedLesson(
            id: existingId ?? UUID(),
            title: trimmed,
            subject: subject,
            tags: TagParser.parse(tagsText),
            revisedDate: Date(),
            periodLabel: periodLabel.trimmingCharacters(in: .whitespacesAndNewlines),
            durationMinutes: durationMinutes,
            isArchived: isArchived
        )
        store.upsertLesson(lesson)
    }
}
