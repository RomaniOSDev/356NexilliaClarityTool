import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UIGestureRecognizerDelegate {
    var window: UIWindow?
    private var launchFlowResolver: LaunchFlowResolver?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        launchFlowResolver = LaunchFlowResolver(window: window)
        window?.rootViewController = launchFlowResolver?.resolveEntryViewController()
        window?.makeKeyAndVisible()
        installKeyboardDismissTap()
    }

    private func installKeyboardDismissTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        window?.addGestureRecognizer(tap)
    }

    @objc private func hideKeyboardOnTap() {
        window?.endEditing(true)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var view = touch.view
        while let current = view {
            if current is UITextField || current is UITextView {
                return false
            }
            view = current.superview
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {
        AppTrackingPrompt.requestIfNeeded()
    }
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
