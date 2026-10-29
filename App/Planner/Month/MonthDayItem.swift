import Foundation

public struct MonthDayItem: Sendable, Hashable, Identifiable {
    public let entry: TimelineEntry
    public let continuesFromPreviousDay: Bool
    public let continuesToNextDay: Bool

    public var id: String {
        entry.id
    }

    public var isSpanning: Bool {
        entry.isAllDay || continuesFromPreviousDay || continuesToNextDay
    }
}
