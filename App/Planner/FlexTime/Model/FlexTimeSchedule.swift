import Foundation

/// The days whose timed events are shown and alerted later than the calendar says.
public struct FlexTimeSchedule: Sendable, Equatable {
    public static let none = FlexTimeSchedule()

    public var delays: [HolidayDay: TimeInterval]

    public init(delays: [HolidayDay: TimeInterval] = [:]) {
        self.delays = delays.filter { $0.value > 0 }
    }

    public var isEmpty: Bool {
        delays.isEmpty
    }

    public func delay(on date: Date, calendar: Calendar) -> TimeInterval {
        guard !isEmpty else { return 0 }
        return delays[HolidayDay(date: date, timeZone: calendar.timeZone)] ?? 0
    }

    public func applying(to events: [CalendarEvent], calendar: Calendar = .current) -> [CalendarEvent] {
        guard !isEmpty else { return events }
        return events.map { event in
            guard !event.isAllDay, !event.isDelayedByFlexTime else { return event }
            let delay = delay(on: event.startDate, calendar: calendar)
            return delay == 0 ? event : event.delayed(by: delay)
        }
    }

    /// Delayed events can enter an interval from before its start, so they are fetched from earlier.
    public func fetchInterval(covering interval: DateInterval) -> DateInterval {
        guard let longestDelay = delays.values.max() else { return interval }
        return DateInterval(start: interval.start.addingTimeInterval(-longestDelay), end: interval.end)
    }

    /// The calendar time that shows up as `interval` once delayed, for saving an item dropped on a delayed day.
    public func scheduledInterval(displayedAs interval: DateInterval, calendar: Calendar = .current) -> DateInterval {
        for delay in Set(delays.values) {
            let scheduledStart = interval.start.addingTimeInterval(-delay)
            if self.delay(on: scheduledStart, calendar: calendar) == delay {
                return DateInterval(start: scheduledStart, duration: interval.duration)
            }
        }
        return interval
    }
}
