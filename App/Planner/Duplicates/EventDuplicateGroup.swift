import Foundation

public struct EventDuplicateGroup: Sendable, Hashable, Identifiable {
    public let primary: CalendarEvent
    public let duplicates: [CalendarEvent]

    public var id: String {
        primary.id
    }

    public var events: [CalendarEvent] {
        [primary] + duplicates
    }

    public var count: Int {
        duplicates.count + 1
    }
}
