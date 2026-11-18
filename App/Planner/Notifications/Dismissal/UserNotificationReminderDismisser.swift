import Foundation
import UserNotifications

/// Clears a completed reminder's delivered alerts and pending snoozes. Its scheduled alerts are left to
/// the next replan unless `removesScheduledAlerts` is set, for writes made while Folio isn't running.
public struct UserNotificationReminderDismisser: ReminderNotificationDismissing {
    private let pendingAlerts: PendingReminderAlerts

    public init(removesScheduledAlerts: Bool = false) {
        pendingAlerts = PendingReminderAlerts(includesScheduledAlerts: removesScheduledAlerts)
    }

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
        let pending = pendingAlerts.identifiers(in: await center.pendingNotificationRequests(), for: reminder)
        if !pending.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: pending)
        }
    }
}
