import Foundation

enum Subject: String, Codable, CaseIterable, Identifiable, Hashable {
    case math = "Math"
    case science = "Science"
    case language = "Language"
    case history = "History"
    case arts = "Arts"

    var id: String { rawValue }

    var stampSymbol: String {
        switch self {
        case .math: return "function"
        case .science: return "leaf"
        case .language: return "text.book.closed"
        case .history: return "clock.arrow.circlepath"
        case .arts: return "paintpalette"
        }
    }
}
