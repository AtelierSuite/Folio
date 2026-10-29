import Foundation

public struct CacheWindowPolicy: Sendable {
    public let paddingWeeks: Int
    public let calendar: Calendar

    public init(paddingWeeks: Int = 4, calendar: Calendar = .current) {
        self.paddingWeeks = paddingWeeks
        self.calendar = calendar
    }

    public func window(around interval: DateInterval) -> DateInterval {
        let startOfFirstDay = calendar.startOfDay(for: interval.start)
        let lastDay = calendar.startOfDay(for: interval.end)
        let startOfDayAfterEnd = lastDay == interval.end
            ? lastDay
            : calendar.date(byAdding: .day, value: 1, to: lastDay) ?? interval.end
        let start = calendar.date(byAdding: .weekOfYear, value: -paddingWeeks, to: startOfFirstDay) ?? interval.start
        let end = calendar.date(byAdding: .weekOfYear, value: paddingWeeks, to: startOfDayAfterEnd) ?? interval.end
        return DateInterval(start: start, end: max(start, end))
    }
}
