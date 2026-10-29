import Foundation

/// Live Activities stay active for at most 8 hours, so a countdown may only start once the event
/// is that close, and keeps going until the end ("ends in…") only when the end is that close too.
public struct CountdownWindow: Sendable {
    public static let defaultLength: TimeInterval = 8 * 60 * 60

    public let length: TimeInterval

    public init(length: TimeInterval = CountdownWindow.defaultLength) {
        self.length = length
    }

    public func availability(for event: CalendarEvent, at now: Date) -> CountdownAvailability {
        if let state = state(for: event, startedAt: now, now: now) {
            return .available(state)
        }
        let opensAt = opensAt(for: event)
        if !event.isAllDay && now < opensAt {
            return .notYet(availableFrom: opensAt)
        }
        return .unavailable
    }

    /// What a countdown begun at `startedAt` should show at `now`, or nil once it should end.
    public func state(
        for event: CalendarEvent,
        startedAt: Date,
        now: Date
    ) -> EventCountdownAttributes.ContentState? {
        guard !event.isAllDay, now < max(event.startDate, event.endDate), startedAt >= opensAt(for: event) else {
            return nil
        }
        let countsToEnd = event.endDate > event.startDate && event.endDate <= startedAt.addingTimeInterval(length)
        guard now < event.startDate || countsToEnd else { return nil }
        return EventCountdownAttributes.ContentState(
            title: event.title,
            location: event.location,
            color: event.color,
            startDate: event.startDate,
            endDate: countsToEnd ? event.endDate : nil
        )
    }

    private func opensAt(for event: CalendarEvent) -> Date {
        event.startDate.addingTimeInterval(-length)
    }
}
