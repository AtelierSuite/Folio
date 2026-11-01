import Foundation

/// Rings `leadTime` before each morning's first timed event, but never before the earliest time of day.
/// Events that start before the earliest time, or from the latest event time on, don't count.
public struct WakeUpAlarmPlanner: Sendable {
    public static let snoozeDuration: TimeInterval = 9 * 60

    public var leadTime: TimeInterval
    public var earliestMinutes: Int
    public var latestEventMinutes: Int
    public var days: Int
    public var calendar: Calendar

    public init(
        leadTime: TimeInterval,
        earliestMinutes: Int,
        latestEventMinutes: Int,
        days: Int = 7,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.leadTime = leadTime
        self.earliestMinutes = earliestMinutes
        self.latestEventMinutes = latestEventMinutes
        self.days = days
        self.calendar = calendar
    }

    public func interval(after now: Date) -> DateInterval {
        let today = calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: days + 1, to: today) ?? now.addingTimeInterval(8 * 86_400)
        return DateInterval(start: today, end: end)
    }

    public func alarms(for events: [CalendarEvent], after now: Date) -> [WakeUpAlarm] {
        let today = calendar.startOfDay(for: now)
        let counted = events.filter { !$0.isAllDay && $0.userStatus != .declined }
        return (0...days).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: today).flatMap { day in
                alarm(on: day, from: counted, after: now)
            }
        }
    }

    private func alarm(on day: Date, from events: [CalendarEvent], after now: Date) -> WakeUpAlarm? {
        guard let earliest = calendar.date(byAdding: .minute, value: earliestMinutes, to: day),
              let latest = calendar.date(byAdding: .minute, value: latestEventMinutes, to: day),
              let first = events
                .filter({ $0.startDate > earliest && $0.startDate < latest })
                .min(by: { ($0.startDate, $0.id) < ($1.startDate, $1.id) }) else { return nil }
        let fireDate = max(earliest, first.startDate.addingTimeInterval(-leadTime))
        return fireDate > now ? WakeUpAlarm(event: first, fireDate: fireDate) : nil
    }
}
