import Foundation

public struct TimelineDaySegment: Sendable, Hashable {
    public let dayIndex: Int
    public let startHour: Double
    public let endHour: Double
    public let continuesFromPreviousDay: Bool
    public let continuesToNextDay: Bool

    public init(
        dayIndex: Int,
        startHour: Double,
        endHour: Double,
        continuesFromPreviousDay: Bool,
        continuesToNextDay: Bool
    ) {
        self.dayIndex = dayIndex
        self.startHour = startHour
        self.endHour = endHour
        self.continuesFromPreviousDay = continuesFromPreviousDay
        self.continuesToNextDay = continuesToNextDay
    }
}
