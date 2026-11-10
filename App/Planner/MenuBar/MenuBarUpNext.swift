import Foundation

/// The next timed event the menu bar item counts down to.
public struct MenuBarUpNext: Sendable, Hashable {
    public static let lookahead: TimeInterval = 24 * 60 * 60

    public let event: CalendarEvent
    public let timeUntilStart: TimeInterval

    public init?(events: [CalendarEvent], at date: Date, lookahead: TimeInterval = Self.lookahead) {
        let horizon = date.addingTimeInterval(lookahead)
        let upcoming = events
            .filter { !$0.isAllDay && $0.startDate > date && $0.startDate <= horizon }
            .min { ($0.startDate, $0.title) < ($1.startDate, $1.title) }
        guard let upcoming else { return nil }
        event = upcoming
        timeUntilStart = upcoming.startDate.timeIntervalSince(date)
    }

    /// Rounded up to the minute, so an event starting in 30 seconds still reads as one minute away.
    public var minutesUntilStart: Int {
        Int((timeUntilStart / 60).rounded(.up))
    }
}
