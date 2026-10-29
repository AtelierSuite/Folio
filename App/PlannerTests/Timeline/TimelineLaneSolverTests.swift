import Testing
@testable import Planner

struct TimelineLaneSolverTests {
    typealias Item = TimelineLaneSolver.Item

    private func span(_ first: Int, _ last: Int) -> Item {
        Item(firstDayIndex: first, lastDayIndex: last)
    }

    @Test func spansOnDifferentDaysShareALane() {
        let lanes = TimelineLaneSolver.lanes(for: [span(0, 1), span(2, 3)])
        #expect(lanes == [0, 0])
    }

    @Test func overlappingSpansStack() {
        let lanes = TimelineLaneSolver.lanes(for: [
            span(0, 2), span(1, 1), span(2, 4)
        ])
        #expect(lanes == [0, 1, 1])
    }

    @Test func longerSpanTakesTheTopLane() {
        let lanes = TimelineLaneSolver.lanes(for: [span(0, 0), span(0, 3)])
        #expect(lanes == [1, 0])
    }

    @Test func gapsAreReused() {
        let lanes = TimelineLaneSolver.lanes(for: [
            span(0, 6), span(0, 1),
            span(1, 2), span(3, 3)
        ])
        #expect(lanes == [0, 1, 2, 1])
    }
}
