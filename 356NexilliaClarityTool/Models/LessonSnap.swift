import Foundation

struct LessonSnap: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var note: String
    var tags: [String]
    var lastEdited: Date
    var linkedLessonId: UUID?
    var subject: Subject
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        title: String,
        note: String,
        tags: [String],
        lastEdited: Date = Date(),
        linkedLessonId: UUID? = nil,
        subject: Subject,
        isArchived: Bool = false
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.tags = tags
        self.lastEdited = lastEdited
        self.linkedLessonId = linkedLessonId
        self.subject = subject
        self.isArchived = isArchived
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        note = try container.decode(String.self, forKey: .note)
        tags = try container.decode([String].self, forKey: .tags)
        lastEdited = try container.decode(Date.self, forKey: .lastEdited)
        linkedLessonId = try container.decodeIfPresent(UUID.self, forKey: .linkedLessonId)
        subject = try container.decode(Subject.self, forKey: .subject)
        isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
    }
}
