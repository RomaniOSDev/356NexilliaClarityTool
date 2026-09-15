import UIKit
import StoreKit

enum AppLinks {
    static let privacy = "https://nexilliaclarity356tool.site/privacy/454"
    static let terms = "https://nexilliaclarity356tool.site/terms/454"

    static func open(_ address: String) {
        guard let url = URL(string: address) else { return }
        UIApplication.shared.open(url)
    }

    static func requestReview() {
        let active = UIApplication.shared.connectedScenes.first { scene in
            scene.activationState == .foregroundActive
        }
        guard let windowScene = active as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: windowScene)
    }
}
