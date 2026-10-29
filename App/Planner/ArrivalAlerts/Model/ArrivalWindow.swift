import Foundation

/// Arrivals count from `lead` before an event starts until `lag` after, but never after the event ends.
public struct ArrivalWindow: Sendable, Equatable {
    public var lead: TimeInterval
    public var lag: TimeInterval

    public init(lead: TimeInterval = 2 * 3600, lag: TimeInterval = 2 * 3600) {
        self.lead = lead
        self.lag = lag
    }

    public func interval(for event: CalendarEvent) -> DateInterval? {
        guard !event.isAllDay else { return nil }
        let start = event.startDate.addingTimeInterval(-lead)
        let end = max(event.startDate, min(event.startDate.addingTimeInterval(lag), event.endDate))
        return DateInterval(start: start, end: end)
    }
}
