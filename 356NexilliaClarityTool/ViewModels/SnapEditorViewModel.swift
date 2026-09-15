import Foundation
import Combine

final class SnapEditorViewModel: ObservableObject {
    @Published var title: String
    @Published var note: String
    @Published var tagsText: String
    @Published var subject: Subject
    @Published var linkedLessonId: UUID?

    private let existingId: UUID?
    private let isArchived: Bool
    let isEditing: Bool

    init(snap: LessonSnap?) {
        if let snap {
            existingId = snap.id
            title = snap.title
            note = snap.note
            tagsText = TagParser.joined(snap.tags)
            subject = snap.subject
            linkedLessonId = snap.linkedLessonId
            isArchived = snap.isArchived
            isEditing = true
        } else {
            existingId = nil
            title = ""
            note = ""
            tagsText = ""
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

    func commit(to store: DataStore) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let linked = linkedLessonId, let lesson = store.lesson(id: linked) {
            subject = lesson.subject
        }
        let snap = LessonSnap(
            id: existingId ?? UUID(),
            title: trimmed,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            tags: TagParser.parse(tagsText),
            lastEdited: Date(),
            linkedLessonId: linkedLessonId,
            subject: subject,
            isArchived: isArchived
        )
        store.upsertSnap(snap)
    }
}
