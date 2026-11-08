import Foundation
import UserNotifications

public struct UserNotificationKeepClient: NotificationKeepClient {
    static let delay: TimeInterval = 1

    let attachmentFactory: NotificationAttachmentFactory

    public init() {
        attachmentFactory = NotificationAttachmentFactory()
    }

    public func keep(_ content: UNNotificationContent, identifier: String) async throws {
        guard let copy = content.mutableCopy() as? UNMutableNotificationContent else { return }
        copy.attachments = attachmentFactory.copies(of: content.attachments)
        // The delay keeps the copy clear of the system removing the alert that was just tapped.
        let request = UNNotificationRequest(
            identifier: identifier,
            content: copy,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: Self.delay, repeats: false)
        )
        try await UNUserNotificationCenter.current().add(request)
    }
}
