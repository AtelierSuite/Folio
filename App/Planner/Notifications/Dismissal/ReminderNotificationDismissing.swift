import Foundation

public protocol ReminderNotificationDismissing: Sendable {
    func dismissNotifications(for reminder: CalendarItemReference) async
}

public struct NoReminderNotificationDismisser: ReminderNotificationDismissing {
    public init() {}

    public func dismissNotifications(for reminder: CalendarItemReference) async {}
}
