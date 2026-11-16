import Foundation
import UserNotifications

/// Clears a completed reminder's delivered alerts and pending snoozes; replanning drops its scheduled alerts.
public struct UserNotificationReminderDismisser: ReminderNotificationDismissing {
    public init() {}

    private var center: UNUserNotificationCenter {
        .current()
    }

    public func dismissNotifications(for reminder: CalendarItemReference) async {
        let delivered = await center.deliveredNotifications()
            .map(\.request)
            .filter { NotificationUserInfo.isAlert($0.content.userInfo, for: reminder) }
            .map(\.identifier)
        if !delivered.isEmpty {
            center.removeDeliveredNotifications(withIdentifiers: delivered)
        }
        let snoozed = await center.pendingNotificationRequests()
            .filter { NotificationSnooze.isSnooze($0.identifier) }
            .filter { NotificationUserInfo.isAlert($0.content.userInfo, for: reminder) }
            .map(\.identifier)
        if !snoozed.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: snoozed)
        }
    }
}
