import Foundation
import Testing
@testable import Planner

struct TimelineDragOperationTests {
    typealias Support = TimelineTestSupport
    typealias Drag = DragTestSupport

    @Test func moveKeepsTheLengthAndSnapsTheStart() {
        let operation = Drag.operation(
            .move, from: Support.date(2026, 10, 27, 9), to: Support.date(2026, 10, 27, 10),
            grabbedAt: Drag.point(2026, 10, 27, hour: 9.4)
        )
        let interval = operation.interval(at: Drag.point(2026, 10, 27, hour: 11.6))
        #expect(interval.start == Support.date(2026, 10, 27, 11, 15))
        #expect(interval.end == Support.date(2026, 10, 27, 12, 15))
    }

    @Test func fiveMinuteSnapping() {
        let operation = Drag.operation(
            .move, from: Support.date(2026, 10, 27, 9), to: Support.date(2026, 10, 27, 9, 30),
            grabbedAt: Drag.point(2026, 10, 27, hour: 9), snap: .fiveMinutes
        )
        let interval = operation.interval(at: Drag.point(2026, 10, 27, hour: 9 + 7.0 / 60))
        #expect(interval.start == Support.date(2026, 10, 27, 9, 5))
    }

    @Test func moveAcrossDaysKeepsTheTime() {
        let operation = Drag.operation(
            .move, from: Support.date(2026, 10, 27, 9), to: Support.date(2026, 10, 27, 10),
            grabbedAt: Drag.point(2026, 10, 27, hour: 9.5)
        )
        let interval = operation.interval(at: Drag.point(2026, 10, 30, hour: 9.5))
        #expect(interval.start == Support.date(2026, 10, 30, 9))
        #expect(interval.end == Support.date(2026, 10, 30, 10))
    }

    @Test func moveStaysInsideTheDay() {
        let operation = Drag.operation(
            .move, from: Support.date(2026, 10, 27, 22), to: Support.date(2026, 10, 27, 23),
            grabbedAt: Drag.point(2026, 10, 27, hour: 22)
        )
        #expect(operation.interval(at: Drag.point(2026, 10, 27, hour: 24)).start == Support.date(2026, 10, 27, 23, 45))
        let early = Drag.operation(
            .move, from: Support.date(2026, 10, 27, 1), to: Support.date(2026, 10, 27, 2),
            grabbedAt: Drag.point(2026, 10, 27, hour: 1.5)
        )
        #expect(early.interval(at: Drag.point(2026, 10, 27, hour: 0)).start == Support.date(2026, 10, 27))
    }

    @Test func moveOntoTheSpringForwardDayKeepsTheWallClockTime() {
        let operation = Drag.operation(
            .move, from: Support.date(2026, 3, 7, 9), to: Support.date(2026, 3, 7, 10),
            grabbedAt: Drag.point(2026, 3, 7, hour: 9)
        )
        let interval = operation.interval(at: Drag.point(2026, 3, 8, hour: 9))
        #expect(interval.start == Support.date(2026, 3, 8, 9))
        #expect(interval.duration == 3600)
    }

    @Test func moveIntoTheSkippedHourLandsAfterIt() {
        let operation = Drag.operation(
            .move, from: Support.date(2026, 3, 8, 0), to: Support.date(2026, 3, 8, 1),
            grabbedAt: Drag.point(2026, 3, 8, hour: 0)
        )
        let interval = operation.interval(at: Drag.point(2026, 3, 8, hour: 2.5))
        #expect(interval.start == Support.date(2026, 3, 8, 3, 30))
    }

    @Test func moveOnTheFallBackDayUsesWallClockHours() {
        let operation = Drag.operation(
            .move, from: Support.date(2026, 11, 1, 6), to: Support.date(2026, 11, 1, 7),
            grabbedAt: Drag.point(2026, 11, 1, hour: 6)
        )
        let interval = operation.interval(at: Drag.point(2026, 11, 1, hour: 9))
        #expect(interval.start == Support.date(2026, 11, 1, 9))
    }

    @Test func resizeEndSnapsAndKeepsAMinimumLength() {
        let operation = Drag.operation(
            .resizeEnd, from: Support.date(2026, 10, 27, 9), to: Support.date(2026, 10, 27, 10),
            grabbedAt: Drag.point(2026, 10, 27, hour: 10)
        )
        #expect(operation.interval(at: Drag.point(2026, 10, 27, hour: 11.8)).end == Support.date(2026, 10, 27, 11, 45))
        let collapsed = operation.interval(at: Drag.point(2026, 10, 27, hour: 7))
        #expect(collapsed.start == Support.date(2026, 10, 27, 9))
        #expect(collapsed.end == Support.date(2026, 10, 27, 9, 15))
    }

    @Test func resizeEndCanReachMidnightAndTheNextDay() {
        let operation = Drag.operation(
            .resizeEnd, from: Support.date(2026, 10, 27, 22), to: Support.date(2026, 10, 28),
            grabbedAt: Drag.point(2026, 10, 27, hour: 24)
        )
        #expect(operation.interval(at: Drag.point(2026, 10, 27, hour: 23)).end == Support.date(2026, 10, 27, 23))
        #expect(operation.interval(at: Drag.point(2026, 10, 28, hour: 1)).end == Support.date(2026, 10, 28, 1))
    }

    @Test func resizeStartKeepsTheEnd() {
        let operation = Drag.operation(
            .resizeStart, from: Support.date(2026, 10, 27, 9), to: Support.date(2026, 10, 27, 10),
            grabbedAt: Drag.point(2026, 10, 27, hour: 9)
        )
        let earlier = operation.interval(at: Drag.point(2026, 10, 27, hour: 7.5))
        #expect(earlier.start == Support.date(2026, 10, 27, 7, 30))
        #expect(earlier.end == Support.date(2026, 10, 27, 10))
        #expect(operation.interval(at: Drag.point(2026, 10, 27, hour: 12)).start == Support.date(2026, 10, 27, 9, 45))
    }

    @Test func placingAReminderSnapsItsStartToThePointer() {
        let operation = Drag.operation(
            .place(duration: 1800), from: Support.date(2026, 10, 27), to: Support.date(2026, 10, 28),
            grabbedAt: Drag.point(2026, 10, 27, hour: 0)
        )
        let interval = operation.interval(at: Drag.point(2026, 10, 29, hour: 14.1))
        #expect(interval.start == Support.date(2026, 10, 29, 14))
        #expect(interval.duration == 1800)
    }
}
