import Foundation
import ImageIO
import Testing
import UniformTypeIdentifiers
import UserNotifications
@testable import Planner

struct NotificationEventImageTests {
    private let event = NotificationFixtures.event("standup", start: NotificationFixtures.hours(2))

    private func plan(image: URL?) -> PlannedNotification? {
        let images = image.map { [event.reference: $0] } ?? [:]
        return NotificationFixtures.planner()
            .plan(events: [event], reminders: [], after: NotificationFixtures.now, budget: 10, eventImages: images)
            .first
    }

    @Test func linkedNoteImageIsCarriedAndChangesTheAlert() throws {
        let plain = try #require(plan(image: nil))
        let first = try #require(plan(image: URL(filePath: "/notes/assets/one.jpg")))
        let second = try #require(plan(image: URL(filePath: "/notes/assets/two.jpg")))
        #expect(plain.imageURL == nil)
        #expect(first.imageURL == URL(filePath: "/notes/assets/one.jpg"))
        #expect(Set([plain.id, first.id, second.id]).count == 3)
        #expect(first.restyled(.timeSensitive).imageURL == first.imageURL)
    }

    @Test func noteImageIsShrunkIntoTheAttachment() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: "EventImageTests-\(UUID())")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let imageURL = directory.appending(path: "photo.png")
        try writeImage(width: 2000, height: 1000, to: imageURL)
        let notification = try #require(plan(image: imageURL))
        let factory = NotificationAttachmentFactory(directory: directory.appending(path: "Attachments"))
        let attachment = try #require(factory.attachments(for: notification).first)
        #expect(attachment.url.pathExtension == "jpeg" || attachment.url.pathExtension == "jpg")
        let thumbnail = try #require(NotificationThumbnailImage.jpegData(from: imageURL))
        let source = try #require(CGImageSourceCreateWithData(thumbnail as CFData, nil))
        let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        #expect(properties?[kCGImagePropertyPixelWidth] as? Int == NotificationThumbnailImage.maximumPixelSize)
    }

    private func writeImage(width: Int, height: Int, to url: URL) throws {
        let context = try #require(CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.setFillColor(CGColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let image = try #require(context.makeImage())
        let destination = try #require(
            CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)
        )
        CGImageDestinationAddImage(destination, image, nil)
        #expect(CGImageDestinationFinalize(destination))
    }
}
