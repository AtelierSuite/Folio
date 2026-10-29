import Foundation

public struct TimelineLayout: Sendable, Equatable {
    public let days: TimelineDays
    public let timedPlacements: [TimelineTimedPlacement]
    public let allDayPlacements: [TimelineAllDayPlacement]

    public var allDayLaneCount: Int {
        (allDayPlacements.map(\.lane).max() ?? -1) + 1
    }

    public func timedPlacements(onDay dayIndex: Int) -> [TimelineTimedPlacement] {
        timedPlacements.filter { $0.dayIndex == dayIndex }
    }
}
