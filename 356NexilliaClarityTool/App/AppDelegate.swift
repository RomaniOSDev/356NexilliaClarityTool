import UIKit
import UserNotifications
import AppsFlyerLib

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        ReminderScheduler.prepare()
        AppsFlyerLib.shared().appsFlyerDevKey = "cqTiFvvyhL5a2SNAqqAna3"
        AppsFlyerLib.shared().appleAppID = "6810656630"
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().isDebug = false
        AppsFlyerLib.shared().disableAdvertisingIdentifier = true
        AppsFlyerLib.shared().start()
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
