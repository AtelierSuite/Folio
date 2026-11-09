import Foundation

/// The watch's timeline: today and the following days that have events, without what has already ended.
public struct WatchAgenda: Sendable, Equatable {
    public struct Day: Identifiable, Sendable, Equatable {
        public let date: Date
        public let allDayEvents: [CalendarEvent]
        public let timedEvents: [CalendarEvent]

        public var id: Date { date }

        public var isEmpty: Bool {
            allDayEvents.isEmpty && timedEvents.isEmpty
        }
    }

    public static let defaultDayCount = 7

    public let days: [Day]

    public init(events: [CalendarEvent], from now: Date, dayCount: Int = Self.defaultDayCount, calendar: Calendar) {
        let remaining = events.filter { $0.endDate > now || ($0.startDate == $0.endDate && $0.startDate >= now) }
        let today = calendar.startOfDay(for: now)
        days = (0..<max(dayCount, 1)).compactMap { offset in
            guard let start = calendar.date(byAdding: .day, value: offset, to: today),
                  let interval = calendar.dateInterval(of: .day, for: start) else { return nil }
            let dayEvents = remaining.filter { $0.overlaps(interval) }
            let day = Day(
                date: interval.start,
                allDayEvents: dayEvents.filter(\.isAllDay),
                timedEvents: dayEvents.filter { !$0.isAllDay }
            )
            return offset == 0 || !day.isEmpty ? day : nil
        }
    }

    public var isEmpty: Bool {
        days.allSatisfy(\.isEmpty)
    }
}
