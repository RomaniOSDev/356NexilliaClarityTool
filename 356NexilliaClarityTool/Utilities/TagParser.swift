import Foundation

enum TagParser {
    static func parse(_ raw: String) -> [String] {
        raw.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    static func joined(_ tags: [String]) -> String {
        tags.joined(separator: ", ")
    }
}
