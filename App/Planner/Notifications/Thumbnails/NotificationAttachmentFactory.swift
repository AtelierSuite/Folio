import Foundation
import UniformTypeIdentifiers
import UserNotifications

/// The system moves an attachment's file into its own store, so every alert gets a fresh copy.
struct NotificationAttachmentFactory: Sendable {
    static let thumbnailIdentifier = "folio.thumbnail"

    let directory: URL

    init(directory: URL = FileManager.default.temporaryDirectory.appending(path: "NotificationAttachments")) {
        self.directory = directory
    }

    func attachments(for notification: PlannedNotification) -> [UNNotificationAttachment] {
        guard let data = artwork(for: notification.kind) else {
            return []
        }
        let url = directory.appending(path: "\(UUID().uuidString).png")
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try data.write(to: url)
            let attachment = try UNNotificationAttachment(
                identifier: Self.thumbnailIdentifier,
                url: url,
                options: [UNNotificationAttachmentOptionsTypeHintKey: UTType.png.identifier]
            )
            return [attachment]
        } catch {
            try? FileManager.default.removeItem(at: url)
            return []
        }
    }

    private func artwork(for kind: CalendarItemKind) -> Data? {
        #if canImport(UIKit)
        NotificationThumbnailArtwork.pngData(for: kind)
        #else
        nil
        #endif
    }
}
