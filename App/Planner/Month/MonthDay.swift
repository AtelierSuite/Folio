import Foundation

public struct MonthDay: Sendable, Hashable, Identifiable {
    public let interval: DateInterval
    public let dayOfMonth: Int
    public let isInMonth: Bool

    public var id: Date {
        interval.start
    }

    public var date: Date {
        interval.start
    }
}
