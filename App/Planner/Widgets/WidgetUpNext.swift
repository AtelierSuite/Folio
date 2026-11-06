import Foundation
import SwiftUI

public struct WidgetUpNext: Sendable, Hashable {
    public let event: CalendarEvent
    public let isOngoing: Bool
    public let following: [CalendarEvent]

    public var joinURL: URL? {
        event.meetingLink?.joinDeepLink
    }

    public var meetingBrandColor: Color? {
        event.meetingLink?.provider.brandColor
    }
}

/// What a Lock Screen widget should say about its event: the start, or the end once it's under way.
public struct WidgetUpNextTiming: Sendable, Hashable {
    public let moment: Date
    public let isOngoing: Bool
    public let isOnAnotherDay: Bool
}

extension WidgetUpNext {
    public func timing(on date: Date, calendar: Calendar) -> WidgetUpNextTiming {
        let moment = isOngoing ? event.endDate : event.startDate
        let lastInstant = isOngoing ? moment.addingTimeInterval(-1) : moment
        return WidgetUpNextTiming(
            moment: moment,
            isOngoing: isOngoing,
            isOnAnotherDay: !calendar.isDate(lastInstant, inSameDayAs: date)
        )
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
