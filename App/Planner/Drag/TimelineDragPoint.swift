import Foundation

/// A pointer position on the timeline as a day and a wall clock hour on that day, so it
/// stays meaningful when the visible days change (paging) during a drag.
public struct TimelineDragPoint: Sendable, Hashable {
    public let dayStart: Date
    public let hour: Double

    public init(dayStart: Date, hour: Double) {
        self.dayStart = dayStart
        self.hour = hour
    }

    public init?(dayIndex: Int, hour: Double, in days: TimelineDays) {
        guard days.intervals.indices.contains(dayIndex) else { return nil }
        self.init(dayStart: days.intervals[dayIndex].start, hour: hour)
    }
}
