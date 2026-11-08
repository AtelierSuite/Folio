import Foundation
import UserNotifications

extension UNNotificationContent {
    static func make(
        _ notification: PlannedNotification,
        attachments: [UNNotificationAttachment] = []
    ) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = notification.content.title
        content.body = notification.content.body
        content.categoryIdentifier = notification.categoryIdentifier
        content.threadIdentifier = notification.category.threadIdentifier
        content.userInfo = NotificationUserInfo.make(for: notification)
        content.attachments = attachments
        apply(notification.style, to: content)
        content.sound = sound(for: notification.sound)
        return content
    }

    private static func apply(_ style: NotificationAlertStyle, to content: UNMutableNotificationContent) {
        switch style {
        case .standard:
            content.interruptionLevel = .active
        case .timeSensitive, .alarm:
            content.interruptionLevel = .timeSensitive
        }
    }

    static func sound(for sound: NotificationSound) -> UNNotificationSound {
        guard let fileName = sound.fileName else { return .default }
        return UNNotificationSound(named: UNNotificationSoundName(fileName))
    }
}
