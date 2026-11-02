import Foundation
import Testing
import UserNotifications
@testable import Planner

struct NotificationAttachmentFactoryTests {
    private let factory = NotificationAttachmentFactory(
        directory: FileManager.default.temporaryDirectory.appending(path: "AttachmentFactoryTests-\(UUID())")
    )

    #if canImport(UIKit)
    @Test func everyAlertGetsItsOwnThumbnailFile() throws {
        let notification = try #require(NotificationActionFixtures.plannedReminder())
        let first = try #require(factory.attachments(for: notification).first)
        let second = try #require(factory.attachments(for: notification).first)
        #expect(first.identifier == NotificationAttachmentFactory.thumbnailIdentifier)
        #expect(first.url != second.url)
    }

    @Test func eventsAndRemindersHaveDifferentArtwork() {
        let event = NotificationThumbnailArtwork.pngData(for: .event)
        #expect(event != nil)
        #expect(event != NotificationThumbnailArtwork.pngData(for: .reminder))
    }

    @Test func artworkIsTintedWithTheCalendarColor() {
        let blue = PlannerColor(red: 0, green: 0.4, blue: 1)
        let tinted = NotificationThumbnailArtwork.pngData(for: .event, color: blue)
        #expect(tinted != nil)
        #expect(tinted != NotificationThumbnailArtwork.pngData(for: .event))
        #expect(tinted == NotificationThumbnailArtwork.pngData(for: .event, color: blue))
    }
    #endif
}
