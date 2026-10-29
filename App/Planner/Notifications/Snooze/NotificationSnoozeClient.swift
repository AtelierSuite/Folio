import Foundation
import UserNotifications

public protocol NotificationSnoozeClient: Sendable {
    func pendingSnoozes() async -> [NotificationSnooze]
    func schedule(_ snooze: NotificationSnooze, content: UNNotificationContent, now: Date) async throws
    func removeSnoozes(withIdentifiers identifiers: [String]) async
}
