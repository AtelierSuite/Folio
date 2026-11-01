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
        let picture = notification.imageURL.flatMap(NotificationThumbnailImage.jpegData(from:))
            .map { (data: $0, type: UTType.jpeg) }
            ?? artwork(for: notification.kind).map { (data: $0, type: UTType.png) }
        guard let picture, let fileExtension = picture.type.preferredFilenameExtension else {
            return []
        }
        let url = directory.appending(path: "\(UUID().uuidString).\(fileExtension)")
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try picture.data.write(to: url)
            let attachment = try UNNotificationAttachment(
                identifier: Self.thumbnailIdentifier,
                url: url,
                options: [UNNotificationAttachmentOptionsTypeHintKey: picture.type.identifier]
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
