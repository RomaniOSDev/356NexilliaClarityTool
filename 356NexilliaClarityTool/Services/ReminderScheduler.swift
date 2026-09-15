import Foundation
import UserNotifications

enum ReminderScheduler {
    static func prepare() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    static func sync(_ plan: LessonPlan) {
        cancel(plan.id)
        guard !plan.isArchived, plan.reminderDate > Date() else { return }
        let content = UNMutableNotificationContent()
        content.title = plan.title
        content.body = "\(plan.subject.rawValue) · local reminder"
        content.sound = .default
        let interval = plan.reminderDate.timeIntervalSinceNow
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(interval, 1), repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier(for: plan.id),
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    static func cancel(_ planId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier(for: planId)]
        )
    }

    static func resync(_ plans: [LessonPlan]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for plan in plans where !plan.isArchived {
            sync(plan)
        }
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private static func identifier(for planId: UUID) -> String {
        "plan.reminder.\(planId.uuidString)"
    }
}
