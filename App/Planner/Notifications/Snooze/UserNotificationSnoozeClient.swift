import Foundation
import UserNotifications

public struct UserNotificationSnoozeClient: NotificationSnoozeClient {
    public init() {}

    private var center: UNUserNotificationCenter {
        .current()
    }

    public func pendingSnoozes() async -> [NotificationSnooze] {
        await center.pendingNotificationRequests().compactMap { request in
            guard NotificationSnooze.isSnooze(request.identifier),
                  let fireDate = (request.trigger as? UNTimeIntervalNotificationTrigger)?.nextTriggerDate() else {
                return nil
            }
            return NotificationSnooze(identifier: request.identifier, fireDate: fireDate)
        }
    }

    public func schedule(_ snooze: NotificationSnooze, content: UNNotificationContent, now: Date) async throws {
        let request = UNNotificationRequest(
            identifier: snooze.identifier,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: max(1, snooze.fireDate.timeIntervalSince(now)), repeats: false)
        )
        try await center.add(request)
    }

    public func removeSnoozes(withIdentifiers identifiers: [String]) async {
        guard !identifiers.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
