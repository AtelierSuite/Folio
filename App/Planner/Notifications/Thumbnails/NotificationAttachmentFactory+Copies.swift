import Foundation
import UserNotifications

extension NotificationAttachmentFactory {
    func copies(of attachments: [UNNotificationAttachment]) -> [UNNotificationAttachment] {
        attachments.compactMap(copy)
    }

    private func copy(of attachment: UNNotificationAttachment) -> UNNotificationAttachment? {
        let source = attachment.url
        let isScoped = source.startAccessingSecurityScopedResource()
        defer {
            if isScoped { source.stopAccessingSecurityScopedResource() }
        }
        let destination = directory.appending(path: "\(UUID().uuidString).\(source.pathExtension)")
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try FileManager.default.copyItem(at: source, to: destination)
            return try UNNotificationAttachment(
                identifier: attachment.identifier,
                url: destination,
                options: [UNNotificationAttachmentOptionsTypeHintKey: attachment.type]
            )
        } catch {
            try? FileManager.default.removeItem(at: destination)
            return nil
        }
    }
}
