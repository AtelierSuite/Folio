import Foundation

public struct TimelineDays: Sendable, Equatable {
    public let calendar: Calendar
    public let intervals: [DateInterval]

    public init(startingOn date: Date, count: Int, calendar: Calendar) {
        self.calendar = calendar
        let firstDayNoon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date) ?? date
        let dayStarts = (0...max(count, 0)).map { offset in
            calendar.startOfDay(for: calendar.date(byAdding: .day, value: offset, to: firstDayNoon) ?? firstDayNoon)
        }
        intervals = zip(dayStarts, dayStarts.dropFirst()).map { DateInterval(start: $0, end: $1) }
    }

    public var count: Int {
        intervals.count
    }

    public var span: DateInterval? {
        guard let first = intervals.first, let last = intervals.last else { return nil }
        return DateInterval(start: first.start, end: last.end)
    }

    public func dayIndex(containing date: Date) -> Int? {
        intervals.firstIndex { $0.start <= date && date < $0.end }
    }

    public func position(of date: Date) -> TimelineTimePosition? {
        guard let dayIndex = dayIndex(containing: date) else { return nil }
        return TimelineTimePosition(dayIndex: dayIndex, hour: hour(of: date, onDay: dayIndex))
    }
}
