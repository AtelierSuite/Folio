import Foundation

public struct SearchRange: Sendable, Hashable {
    public static let `default` = SearchRange(monthsBack: 24, monthsAhead: 12)

    public var monthsBack: Int
    public var monthsAhead: Int

    public init(monthsBack: Int, monthsAhead: Int) {
        self.monthsBack = max(0, monthsBack)
        self.monthsAhead = max(0, monthsAhead)
    }

    public func interval(around date: Date, calendar: Calendar = .current) -> DateInterval {
        let today = calendar.startOfDay(for: date)
        let start = calendar.date(byAdding: .month, value: -monthsBack, to: today) ?? today
        let end = calendar.date(byAdding: .month, value: monthsAhead, to: today)
            .flatMap { calendar.date(byAdding: .day, value: 1, to: $0) } ?? today
        return DateInterval(start: start, end: max(start, end))
    }
}
