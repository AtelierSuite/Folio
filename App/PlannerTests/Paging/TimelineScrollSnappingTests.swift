import CoreGraphics
import Testing
@testable import Planner

struct TimelineScrollSnappingTests {
    @Test func dayFlingSettlesOnTheNearestDay() {
        let snapping = TimelineScrollSnapping(columnsOnScreen: 3)
        let target = snapping.targetOffset(proposed: 1_030, start: 300, containerWidth: 300, contentWidth: 10_000)
        #expect(target == 1_000)
    }

    @Test func dayFlingCanCrossManyDays() {
        let snapping = TimelineScrollSnapping(columnsOnScreen: 1)
        let target = snapping.targetOffset(proposed: 2_480, start: 400, containerWidth: 400, contentWidth: 10_000)
        #expect(target == 2_400)
    }

    @Test func weekFlingStopsAfterOneWeek() {
        let snapping = TimelineScrollSnapping(columnsOnScreen: 7, columnsPerStep: 7, limitsToOneStep: true)
        let forward = snapping.targetOffset(proposed: 3_000, start: 700, containerWidth: 700, contentWidth: 10_000)
        #expect(forward == 1_400)
        let backward = snapping.targetOffset(proposed: -900, start: 700, containerWidth: 700, contentWidth: 10_000)
        #expect(backward == 0)
    }

    @Test func shortWeekDragSettlesBack() {
        let snapping = TimelineScrollSnapping(columnsOnScreen: 5, columnsPerStep: 5, limitsToOneStep: true)
        let target = snapping.targetOffset(proposed: 820, start: 700, containerWidth: 700, contentWidth: 10_000)
        #expect(target == 700)
    }

    @Test func targetStaysWithinTheContent() {
        let snapping = TimelineScrollSnapping(columnsOnScreen: 2)
        #expect(snapping.targetOffset(proposed: -300, start: 0, containerWidth: 400, contentWidth: 2_000) == 0)
        #expect(snapping.targetOffset(proposed: 5_000, start: 0, containerWidth: 400, contentWidth: 2_000) == 1_600)
    }

    @Test func zeroWidthLeavesTheTargetAlone() {
        let snapping = TimelineScrollSnapping(columnsOnScreen: 3)
        #expect(snapping.targetOffset(proposed: 123, start: 0, containerWidth: 0, contentWidth: 0) == 123)
    }
}
