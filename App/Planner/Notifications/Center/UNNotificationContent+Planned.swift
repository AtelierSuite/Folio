import Foundation
import UserNotifications

extension UNNotificationContent {
    static func make(_ notification: PlannedNotification) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = notification.content.title
        content.body = notification.content.body
        content.categoryIdentifier = notification.categoryIdentifier
        content.threadIdentifier = notification.category.threadIdentifier
        content.userInfo = NotificationUserInfo.make(for: notification)
        apply(notification.style, to: content)
        return content
    }

    private static func apply(_ style: NotificationAlertStyle, to content: UNMutableNotificationContent) {
        switch style {
        case .standard:
            content.sound = .default
            content.interruptionLevel = .active
        case .timeSensitive, .alarm:
            content.sound = .default
            content.interruptionLevel = .timeSensitive
        }
    }
}
