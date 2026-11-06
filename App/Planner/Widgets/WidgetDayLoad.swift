import Foundation

/// Today's busy and open time between `firstHour` and `lastHour`. Travel counts as busy.
public struct WidgetDayLoad: Sendable, Equatable {
    public enum Status: Sendable, Equatable {
        case free(until: Date)
        case busy(until: Date)
        case dayOver
    }

    public static let firstHour = 8
    public static let lastHour = 22
    public static let shortestGap: TimeInterval = 15 * 60

    public let window: DateInterval
    public let busyIntervals: [DateInterval]
    public let gaps: [DateInterval]
    public let status: Status

    public init(events: [CalendarEvent], travel: [DateInterval] = [], at now: Date, calendar: Calendar) {
        let window = Self.window(on: now, calendar: calendar)
        let busy = Self.merged(
            events.filter { !$0.isAllDay && !$0.isDeclined }.map { DateInterval(start: $0.startDate, end: $0.endDate) }
                + travel,
            in: window
        )
        self.window = window
        busyIntervals = busy
        gaps = Self.gaps(between: busy, in: window, after: now)
        status = Self.status(busy: busy, in: window, at: now)
    }

    public var longestGap: DateInterval? {
        gaps.max { $0.duration < $1.duration }
    }

    static func window(on day: Date, calendar: Calendar) -> DateInterval {
        let start = calendar.date(bySettingHour: firstHour, minute: 0, second: 0, of: day) ?? day
        let end = calendar.date(bySettingHour: lastHour, minute: 0, second: 0, of: day) ?? day
        return DateInterval(start: start, end: max(start, end))
    }

    private static func merged(_ intervals: [DateInterval], in window: DateInterval) -> [DateInterval] {
        intervals
            .compactMap { $0.intersection(with: window) }
            .filter { $0.duration > 0 }
            .sorted { $0.start < $1.start }
            .reduce(into: []) { merged, interval in
                if let last = merged.last, interval.start <= last.end {
                    merged[merged.count - 1] = DateInterval(start: last.start, end: max(last.end, interval.end))
                } else {
                    merged.append(interval)
                }
            }
    }

    private static func gaps(
        between busy: [DateInterval],
        in window: DateInterval,
        after now: Date
    ) -> [DateInterval] {
        var cursor = max(window.start, now)
        var gaps: [DateInterval] = []
        for interval in busy + [DateInterval(start: window.end, duration: 0)] {
            if interval.start > cursor {
                gaps.append(DateInterval(start: cursor, end: interval.start))
            }
            cursor = max(cursor, interval.end)
        }
        return gaps.filter { $0.duration >= shortestGap }
    }

    private static func status(busy: [DateInterval], in window: DateInterval, at now: Date) -> Status {
        guard now < window.end else { return .dayOver }
        if let current = busy.first(where: { $0.start <= now && now < $0.end }) {
            return .busy(until: current.end)
        }
        return .free(until: busy.first { $0.start > now }?.start ?? window.end)
    }
}

extension WidgetSnapshot {
    public func dayLoad(at date: Date, calendar: Calendar) -> WidgetDayLoad {
        WidgetDayLoad(events: events, at: date, calendar: calendar)
    }
}
