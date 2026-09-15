import Foundation

enum ReminderUrgency: String {
    case overdue
    case today
    case tomorrow
    case later

    static func of(_ date: Date, now: Date = Date()) -> ReminderUrgency {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: now)
        let day = calendar.startOfDay(for: date)
        let diff = calendar.dateComponents([.day], from: start, to: day).day ?? 0
        if diff < 0 { return .overdue }
        if diff == 0 { return .today }
        if diff == 1 { return .tomorrow }
        return .later
    }

    var label: String {
        switch self {
        case .overdue: return "Overdue"
        case .today: return "Today"
        case .tomorrow: return "Tomorrow"
        case .later: return "Later"
        }
    }
}

enum PlanTemplate: String, CaseIterable, Identifiable {
    case warmup = "Warm-up"
    case main = "Main sequence"
    case exit = "Exit ticket"

    var id: String { rawValue }

    var chipTitle: String {
        switch self {
        case .warmup: return "Warm-up"
        case .main: return "Main"
        case .exit: return "Exit"
        }
    }

    var fill: String {
        switch self {
        case .warmup:
            return "WARM-UP\nDo Now:\nMaterials:\nTime: 5–8 min"
        case .main:
            return "MAIN SEQUENCE\nObjective:\nI do / We do / You do:\nChecks for understanding:\nTime:"
        case .exit:
            return "EXIT TICKET\nPrompt:\nSuccess look-for:\nCollect / share:"
        }
    }
}

struct LessonPlan: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var description: String
    var tags: [String]
    var reminderDate: Date
    var needsRevision: Bool
    var subject: Subject
    var linkedLessonId: UUID?
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        tags: [String],
        reminderDate: Date,
        needsRevision: Bool,
        subject: Subject,
        linkedLessonId: UUID? = nil,
        isArchived: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.tags = tags
        self.reminderDate = reminderDate
        self.needsRevision = needsRevision
        self.subject = subject
        self.linkedLessonId = linkedLessonId
        self.isArchived = isArchived
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        tags = try container.decode([String].self, forKey: .tags)
        reminderDate = try container.decode(Date.self, forKey: .reminderDate)
        needsRevision = try container.decode(Bool.self, forKey: .needsRevision)
        subject = try container.decode(Subject.self, forKey: .subject)
        linkedLessonId = try container.decodeIfPresent(UUID.self, forKey: .linkedLessonId)
        isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
    }

    var urgency: ReminderUrgency { ReminderUrgency.of(reminderDate) }
}
