import Foundation
import Combine

final class BoardViewModel: ObservableObject {
    struct Cluster: Identifiable {
        let subject: Subject
        var id: String { subject.rawValue }
        let lessonCount: Int
        let snapCount: Int
        let planCount: Int
        let revisionCount: Int
        let titles: [String]

        var total: Int { lessonCount + snapCount + planCount }
    }

    @Published private(set) var clusters: [Cluster] = []
    @Published private(set) var grandTotal: Int = 0

    func rebuild(from store: DataStore) {
        var built: [Cluster] = []
        for subject in Subject.allCases {
            let lessonHits = store.activeLessons.filter { $0.subject == subject }
            let snapHits = store.activeSnaps.filter { store.resolvedSubject(for: $0) == subject }
            let planHits = store.activePlans.filter { store.resolvedSubject(for: $0) == subject }
            let revisions = planHits.filter(\.needsRevision).count
            var titles: [String] = []
            titles.append(contentsOf: lessonHits.map(\.title))
            titles.append(contentsOf: snapHits.map(\.title))
            titles.append(contentsOf: planHits.map(\.title))
            built.append(
                Cluster(
                    subject: subject,
                    lessonCount: lessonHits.count,
                    snapCount: snapHits.count,
                    planCount: planHits.count,
                    revisionCount: revisions,
                    titles: Array(titles.prefix(4))
                )
            )
        }
        clusters = built
        grandTotal = store.activeLessons.count + store.activeSnaps.count + store.activePlans.count
    }
}
