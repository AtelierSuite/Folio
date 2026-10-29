import Foundation

public struct NotificationSnooze: Sendable, Hashable {
    public static let prefix = "folio.snooze."

    public let identifier: String
    public let fireDate: Date

    public init(identifier: String, fireDate: Date) {
        self.identifier = identifier
        self.fireDate = fireDate
    }

    /// Snoozing an item again replaces its earlier snooze.
    public init(item: NotificationItem, fireDate: Date) {
        self.init(identifier: Self.identifier(for: item), fireDate: fireDate)
    }

    public static func identifier(for item: NotificationItem) -> String {
        "\(prefix)\(item.kind.rawValue).\(item.reference.storageKey)"
    }

    public static func isSnooze(_ identifier: String) -> Bool {
        identifier.hasPrefix(prefix)
    }
}
