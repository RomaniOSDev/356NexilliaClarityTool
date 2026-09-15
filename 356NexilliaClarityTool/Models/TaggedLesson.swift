import Foundation

struct TaggedLesson: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var subject: Subject
    var tags: [String]
    var revisedDate: Date
    var periodLabel: String
    var durationMinutes: Int
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        title: String,
        subject: Subject,
        tags: [String],
        revisedDate: Date = Date(),
        periodLabel: String = "",
        durationMinutes: Int = 45,
        isArchived: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subject = subject
        self.tags = tags
        self.revisedDate = revisedDate
        self.periodLabel = periodLabel
        self.durationMinutes = durationMinutes
        self.isArchived = isArchived
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        subject = try container.decode(Subject.self, forKey: .subject)
        tags = try container.decode([String].self, forKey: .tags)
        revisedDate = try container.decode(Date.self, forKey: .revisedDate)
        periodLabel = try container.decodeIfPresent(String.self, forKey: .periodLabel) ?? ""
        durationMinutes = try container.decodeIfPresent(Int.self, forKey: .durationMinutes) ?? 45
        isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
    }

    var periodStamp: String {
        let period = periodLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        if period.isEmpty {
            return "\(durationMinutes) min"
        }
        return "\(period) · \(durationMinutes) min"
    }
}
