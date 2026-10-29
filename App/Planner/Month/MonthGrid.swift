import Foundation

public struct MonthGrid: Sendable, Equatable {
    public static let daysPerWeek = 7

    public let calendar: Calendar
    public let month: DateInterval
    public let weeks: [MonthWeek]

    public init(containing date: Date, calendar: Calendar) {
        self.calendar = calendar
        let month = Self.monthInterval(containing: date, calendar: calendar)
        self.month = month
        let firstWeekday = calendar.component(.weekday, from: month.start)
        let leadingDayCount = (firstWeekday - calendar.firstWeekday + Self.daysPerWeek) % Self.daysPerWeek
        let monthDayCount = calendar.range(of: .day, in: .month, for: month.start)?.count ?? 0
        let weekCount = (leadingDayCount + monthDayCount + Self.daysPerWeek - 1) / Self.daysPerWeek
        let monthNoon = Self.noon(of: month.start, calendar: calendar)
        let gridStart = calendar.date(byAdding: .day, value: -leadingDayCount, to: monthNoon)
        let timelineDays = TimelineDays(
            startingOn: gridStart ?? month.start, count: weekCount * Self.daysPerWeek, calendar: calendar
        )
        let days = timelineDays.intervals.map { interval in
            MonthDay(
                interval: interval,
                dayOfMonth: calendar.component(.day, from: interval.start),
                isInMonth: month.start <= interval.start && interval.start < month.end
            )
        }
        weeks = stride(from: 0, to: days.count, by: Self.daysPerWeek).map { offset in
            let weekDays = Array(days[offset..<offset + Self.daysPerWeek])
            return MonthWeek(days: weekDays, weekNumber: Self.isoWeekNumber(of: weekDays, calendar: calendar))
        }
    }

    public var days: [MonthDay] {
        weeks.flatMap(\.days)
    }

    public var span: DateInterval? {
        guard let first = weeks.first?.interval, let last = weeks.last?.interval else { return nil }
        return DateInterval(start: first.start, end: last.end)
    }

    public var orderedWeekdays: [Int] {
        (0..<Self.daysPerWeek).map { offset in
            (calendar.firstWeekday - 1 + offset) % Self.daysPerWeek + 1
        }
    }

    public func day(containing date: Date) -> MonthDay? {
        days.first { $0.interval.start <= date && date < $0.interval.end }
    }

    static func monthInterval(containing date: Date, calendar: Calendar) -> DateInterval {
        if let interval = calendar.dateInterval(of: .month, for: date) {
            return interval
        }
        let start = calendar.startOfDay(for: date)
        return DateInterval(start: start, duration: 0)
    }

    static func noon(of date: Date, calendar: Calendar) -> Date {
        calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date) ?? date
    }
}
