import Foundation

/// The event or reminder an alert was delivered for.
public struct NotificationItem: Sendable, Hashable {
    public let kind: CalendarItemKind
    public let reference: CalendarItemReference
    public let fireDate: Date

    public init(kind: CalendarItemKind, reference: CalendarItemReference, fireDate: Date) {
        self.kind = kind
        self.reference = reference
        self.fireDate = fireDate
    }

    public var date: Date {
        reference.startDate ?? reference.occurrenceDate ?? fireDate
    }

    public var destination: AppDestination {
        .calendarDay(date, item: reference)
    }
}

extension NotificationUserInfo {
    public static func item(from userInfo: [AnyHashable: Any]) -> NotificationItem? {
        guard let kind = kind(from: userInfo), let reference = reference(from: userInfo) else { return nil }
        return NotificationItem(kind: kind, reference: reference, fireDate: fireDate(from: userInfo) ?? reference.startDate ?? .now)
    }
}
