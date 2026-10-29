import Foundation
@testable import Planner

enum DragTestSupport {
    typealias Support = TimelineTestSupport

    static func operation(
        _ kind: TimelineDragKind,
        from start: Date,
        to end: Date,
        grabbedAt origin: TimelineDragPoint,
        snap: TimelineDragSnap = .fifteenMinutes
    ) -> TimelineDragOperation {
        TimelineDragOperation(
            kind: kind,
            original: DateInterval(start: start, end: end),
            origin: origin,
            calendar: Support.calendar(),
            snap: snap
        )
    }

    static func point(_ year: Int, _ month: Int, _ day: Int, hour: Double) -> TimelineDragPoint {
        TimelineDragPoint(dayStart: Support.date(year, month, day), hour: hour)
    }
}
