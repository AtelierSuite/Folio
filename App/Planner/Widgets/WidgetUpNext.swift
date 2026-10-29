import Foundation

public struct WidgetUpNext: Sendable, Hashable {
    public let event: CalendarEvent
    public let isOngoing: Bool
    public let following: [CalendarEvent]

    public var joinURL: URL? {
        event.meetingLink?.joinDeepLink
    }
}

extension WidgetSnapshot {
    public func upNext(at date: Date, followingLimit: Int = 2) -> WidgetUpNext? {
        let remaining = events.filter { !$0.isAllDay && $0.endDate > date }
        guard let event = remaining.first else { return nil }
        return WidgetUpNext(
            event: event,
            isOngoing: event.startDate <= date,
            following: Array(remaining.dropFirst().prefix(followingLimit))
        )
    }
}
