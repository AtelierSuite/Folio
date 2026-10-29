import Foundation

public struct MonthWeek: Sendable, Hashable, Identifiable {
    public let days: [MonthDay]
    public let weekNumber: Int

    public var id: Date {
        days.first?.id ?? .distantPast
    }

    public var interval: DateInterval? {
        guard let first = days.first, let last = days.last else { return nil }
        return DateInterval(start: first.interval.start, end: last.interval.end)
    }
}
