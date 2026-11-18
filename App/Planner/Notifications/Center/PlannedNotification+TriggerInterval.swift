import Foundation

extension PlannedNotification {
    /// Seconds from `date` until the alert fires, at least 1 as `UNTimeIntervalNotificationTrigger` requires.
    func triggerInterval(from date: Date) -> TimeInterval {
        max(1, fireDate.timeIntervalSince(date))
    }
}
