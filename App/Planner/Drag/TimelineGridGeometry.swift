import CoreGraphics
import Foundation

/// Converts points in the time grid (hour 0 at the top, the first day on the leading edge)
/// into days and hours.
public struct TimelineGridGeometry: Sendable, Equatable {
    public var width: CGFloat
    public var dayCount: Int
    public var hourHeight: CGFloat

    public init(width: CGFloat, dayCount: Int, hourHeight: CGFloat) {
        self.width = width
        self.dayCount = dayCount
        self.hourHeight = hourHeight
    }

    public var dayWidth: CGFloat {
        width / CGFloat(max(dayCount, 1))
    }

    public func dayIndex(atX xPosition: CGFloat) -> Int {
        guard dayWidth > 0 else { return 0 }
        let index = Int((xPosition / dayWidth).rounded(.down))
        return min(max(index, 0), max(dayCount - 1, 0))
    }

    public func hour(atY yPosition: CGFloat) -> Double {
        guard hourHeight > 0 else { return 0 }
        return min(max(Double(yPosition / hourHeight), 0), TimelineDays.hoursPerDay)
    }

    public func y(ofHour hour: Double) -> CGFloat {
        CGFloat(hour) * hourHeight
    }

    /// Where `xPosition` falls across its day column, from 0 at the leading edge to 1 at the trailing edge.
    public func fractionWithinDay(atX xPosition: CGFloat) -> Double {
        guard dayWidth > 0 else { return 0 }
        let offset = xPosition - CGFloat(dayIndex(atX: xPosition)) * dayWidth
        return min(max(Double(offset / dayWidth), 0), 1)
    }

    public func point(at location: CGPoint, in days: TimelineDays) -> TimelineDragPoint? {
        TimelineDragPoint(dayIndex: dayIndex(atX: location.x), hour: hour(atY: location.y), in: days)
    }
}
