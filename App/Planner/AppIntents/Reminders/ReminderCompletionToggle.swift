import Foundation

/// Marks a reminder done or not done from outside the app, clearing its alerts when it is done.
public struct ReminderCompletionToggle: Sendable {
    private let source: any CalendarDataSource
    private let notifications: any ReminderNotificationDismissing

    public init(
        source: any CalendarDataSource = EventKitDataSource.shared,
        notifications: any ReminderNotificationDismissing =
            UserNotificationReminderDismisser(removesScheduledAlerts: true)
    ) {
        self.source = source
        self.notifications = notifications
    }

    public func setCompleted(_ isCompleted: Bool, reminderIdentifier: String) async throws {
        try await source.setCompleted(isCompleted, reminderIdentifier: reminderIdentifier)
        guard isCompleted else { return }
        await notifications.dismissNotifications(for: CalendarItemReference(
            externalIdentifier: nil, localIdentifier: reminderIdentifier, calendarIdentifier: "", title: ""
        ))
    }
}
