import Foundation

enum DateDisplay {
    static let roster: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let inked: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    static let shortDayStamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter
    }()

    static func roster(_ date: Date) -> String {
        roster.string(from: date)
    }

    static func inked(_ date: Date) -> String {
        inked.string(from: date)
    }

    static let weekdayStamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    static let monthDayStamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter
    }()

    static func shortDay(_ date: Date) -> String {
        shortDayStamp.string(from: date)
    }

    static func weekday(_ date: Date) -> String {
        weekdayStamp.string(from: date)
    }

    static func monthDay(_ date: Date) -> String {
        monthDayStamp.string(from: date)
    }
}
