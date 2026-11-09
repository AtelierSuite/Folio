import Foundation

/// Rings `leadTime`, plus the travel time to the event when there is one, before each morning's first event,
/// but never before the earliest time of day. Events that start before the earliest time,
/// or from the latest event time on, don't count. Days in `skippedDays` never ring.
public struct WakeUpAlarmPlanner: Sendable {
    public static let snoozeDuration: TimeInterval = 9 * 60

    public var leadTime: TimeInterval
    public var earliestMinutes: Int
    public var latestEventMinutes: Int
    public var days: Int
    public var skippedDays: Set<HolidayDay>
    public var calendar: Calendar

    public init(
        leadTime: TimeInterval,
        earliestMinutes: Int,
        latestEventMinutes: Int,
        days: Int = 7,
        skippedDays: Set<HolidayDay> = [],
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.leadTime = leadTime
        self.earliestMinutes = earliestMinutes
        self.latestEventMinutes = latestEventMinutes
        self.days = days
        self.skippedDays = skippedDays
        self.calendar = calendar
    }

    public func interval(after now: Date) -> DateInterval {
        let today = calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: days + 1, to: today) ?? now.addingTimeInterval(8 * 86_400)
        return DateInterval(start: today, end: end)
    }

    /// The upcoming events that could set off an alarm, worth a travel time estimate.
    public func morningEvents(in events: [CalendarEvent], after now: Date) -> [CalendarEvent] {
        mornings(for: events, after: now).flatMap(\.events).filter { $0.startDate > now }
    }

    /// `travelTimes` holds how long it takes to reach an event, keyed by event ID.
    public func alarms(
        for events: [CalendarEvent],
        after now: Date,
        travelTimes: [String: TimeInterval] = [:]
    ) -> [WakeUpAlarm] {
        mornings(for: events, after: now).compactMap { morning in
            alarm(for: morning, travelTimes: travelTimes, after: now)
        }
    }

    private struct Morning {
        let earliest: Date
        let events: [CalendarEvent]
    }

    private func mornings(for events: [CalendarEvent], after now: Date) -> [Morning] {
        let today = calendar.startOfDay(for: now)
        let counted = events.filter { !$0.isAllDay && $0.userStatus != .declined }
        return (0...days).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: today).flatMap { day in
                morning(on: day, from: counted)
            }
        }
    }

    private func morning(on day: Date, from events: [CalendarEvent]) -> Morning? {
        guard !skippedDays.contains(HolidayDay(date: day, timeZone: calendar.timeZone)),
              let earliest = calendar.date(byAdding: .minute, value: earliestMinutes, to: day),
              let latest = calendar.date(byAdding: .minute, value: latestEventMinutes, to: day) else { return nil }
        let events = events.filter { $0.startDate > earliest && $0.startDate < latest }
        return events.isEmpty ? nil : Morning(earliest: earliest, events: events)
    }

    private func alarm(for morning: Morning, travelTimes: [String: TimeInterval], after now: Date) -> WakeUpAlarm? {
        func wakeDate(for event: CalendarEvent) -> Date {
            event.startDate.addingTimeInterval(-leadTime - (travelTimes[event.id] ?? 0))
        }
        guard let first = morning.events.min(by: {
            (wakeDate(for: $0), $0.startDate, $0.id) < (wakeDate(for: $1), $1.startDate, $1.id)
        }) else { return nil }
        let fireDate = max(morning.earliest, wakeDate(for: first))
        guard fireDate > now else { return nil }
        return WakeUpAlarm(event: first, fireDate: fireDate, travelTime: travelTimes[first.id])
    }
}
