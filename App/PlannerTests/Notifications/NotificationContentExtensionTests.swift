import Foundation
import Testing
import UserNotifications
@testable import Planner

struct NotificationContentExtensionTests {
    /// The content extension only handles the categories listed in its Info.plist.
    @Test func contentExtensionHandlesEveryCategory() throws {
        let plistURL = URL(filePath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appending(path: "NotificationContent/Info.plist")
        let plist = try #require(
            try PropertyListSerialization.propertyList(from: Data(contentsOf: plistURL), format: nil) as? [String: Any]
        )
        let attributes = (plist["NSExtension"] as? [String: Any])?["NSExtensionAttributes"] as? [String: Any]
        let categories = try #require(attributes?["UNNotificationExtensionCategory"] as? [String])
        #expect(Set(categories) == Set(NotificationCategoryRegistry.allCategories(snoozing: .standard).map(\.identifier)))
    }
}
