import Foundation
import UserNotifications

public protocol NotificationKeepClient: Sendable {
    func keep(_ content: UNNotificationContent, identifier: String) async throws
}
