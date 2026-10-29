import Testing
@testable import Planner

struct TimelineColumnSolverTests {
    typealias Item = TimelineColumnSolver.Item
    typealias Assignment = TimelineColumnSolver.Assignment

    @Test func separateItemsTakeTheFullWidth() {
        let assignments = TimelineColumnSolver.assignments(for: [Item(start: 9, end: 10), Item(start: 10, end: 11)])
        #expect(assignments == [
            Assignment(column: 0, columnSpan: 1, columnCount: 1),
            Assignment(column: 0, columnSpan: 1, columnCount: 1)
        ])
    }

    @Test func overlappingItemsShareTheWidth() {
        let assignments = TimelineColumnSolver.assignments(for: [
            Item(start: 9, end: 11), Item(start: 10, end: 12), Item(start: 10.5, end: 11.5)
        ])
        #expect(assignments.map(\.column) == [0, 1, 2])
        #expect(assignments.allSatisfy { $0.columnCount == 3 && $0.columnSpan == 1 })
    }

    @Test func chainedOverlapsFormOneCluster() {
        let assignments = TimelineColumnSolver.assignments(for: [
            Item(start: 9, end: 10), Item(start: 9.5, end: 11), Item(start: 10.5, end: 12)
        ])
        #expect(assignments.map(\.column) == [0, 1, 0])
        #expect(assignments.allSatisfy { $0.columnCount == 2 })
    }

    @Test func itemsWidenIntoFreeColumns() {
        let assignments = TimelineColumnSolver.assignments(for: [
            Item(start: 9, end: 12), Item(start: 9, end: 10), Item(start: 9, end: 10), Item(start: 11, end: 12)
        ])
        #expect(assignments[0] == Assignment(column: 0, columnSpan: 1, columnCount: 3))
        #expect(assignments[3] == Assignment(column: 1, columnSpan: 2, columnCount: 3))
    }

    @Test func longerItemTakesTheFirstColumnWhenStartsMatch() {
        let assignments = TimelineColumnSolver.assignments(for: [Item(start: 9, end: 10), Item(start: 9, end: 12)])
        #expect(assignments.map(\.column) == [1, 0])
    }

    @Test func emptyInputGivesNoAssignments() {
        #expect(TimelineColumnSolver.assignments(for: []).isEmpty)
    }
}
