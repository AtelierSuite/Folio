import Foundation
import UserNotifications

/// The pending requests to remove when a reminder is done: always its snoozes, and its scheduled
/// alerts when no replan will follow to drop them.
struct PendingReminderAlerts {
    let includesScheduledAlerts: Bool

    func identifiers(in requests: [UNNotificationRequest], for reminder: CalendarItemReference) -> [String] {
        requests
            .filter { isRemovable($0.identifier) }
            .filter { NotificationUserInfo.isAlert($0.content.userInfo, for: reminder) }
            .map(\.identifier)
    }

    private func isRemovable(_ identifier: String) -> Bool {
        if NotificationSnooze.isSnooze(identifier) { return true }
        return includesScheduledAlerts && NotificationIdentifier.isOwned(identifier)
    }
}
