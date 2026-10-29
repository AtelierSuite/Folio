import Foundation
import UserNotifications

public struct UserNotificationCenterClient: NotificationCenterClient {
    public init() {}

    private var center: UNUserNotificationCenter {
        .current()
    }

    public func authorization() async -> NotificationAuthorization {
        switch await center.notificationSettings().authorizationStatus {
        case .notDetermined: .notDetermined
        case .authorized, .provisional, .ephemeral: .authorized
        case .denied: .denied
        @unknown default: .denied
        }
    }

    public func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    public func pendingIdentifiers() async -> [String] {
        await center.pendingNotificationRequests().map(\.identifier)
    }

    public func add(_ notification: PlannedNotification, now: Date) async throws {
        let interval = max(1, notification.fireDate.timeIntervalSince(now))
        let request = UNNotificationRequest(
            identifier: notification.id,
            content: UNNotificationContent.make(notification),
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        )
        try await center.add(request)
    }

    public func removePending(withIdentifiers identifiers: [String]) async {
        guard !identifiers.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
