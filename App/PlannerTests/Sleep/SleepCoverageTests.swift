import Foundation
import Testing
@testable import Planner

struct SleepCoverageTests {
    private typealias Fixture = SleepFixtures

    @Test func emptyCoverageLeavesIntervalWhole() {
        let interval = DateInterval(start: Fixture.time(1), end: Fixture.time(2))
        #expect(SleepCoverage().uncovered(interval) == [interval])
    }

    @Test func coveredMiddleSplitsInterval() {
        var coverage = SleepCoverage()
        coverage.insert(DateInterval(start: Fixture.time(2), end: Fixture.time(3)))
        let pieces = coverage.uncovered(DateInterval(start: Fixture.time(1), end: Fixture.time(4)))
        #expect(pieces == [
            DateInterval(start: Fixture.time(1), end: Fixture.time(2)),
            DateInterval(start: Fixture.time(3), end: Fixture.time(4))
        ])
    }

    @Test func fullyCoveredIntervalHasNoPieces() {
        var coverage = SleepCoverage()
        coverage.insert(DateInterval(start: Fixture.time(1), end: Fixture.time(5)))
        #expect(coverage.uncovered(DateInterval(start: Fixture.time(2), end: Fixture.time(3))).isEmpty)
    }

    @Test func overlappingAndTouchingInsertsMerge() {
        var coverage = SleepCoverage()
        coverage.insert(DateInterval(start: Fixture.time(3), end: Fixture.time(4)))
        coverage.insert(DateInterval(start: Fixture.time(1), end: Fixture.time(2)))
        coverage.insert(DateInterval(start: Fixture.time(2), end: Fixture.time(3, 30)))
        coverage.insert(DateInterval(start: Fixture.time(6), end: Fixture.time(7)))
        #expect(coverage.intervals == [
            DateInterval(start: Fixture.time(1), end: Fixture.time(4)),
            DateInterval(start: Fixture.time(6), end: Fixture.time(7))
        ])
    }

    @Test func multipleGapsAreReturnedInOrder() {
        var coverage = SleepCoverage()
        coverage.insert(DateInterval(start: Fixture.time(2), end: Fixture.time(3)))
        coverage.insert(DateInterval(start: Fixture.time(4), end: Fixture.time(5)))
        let pieces = coverage.uncovered(DateInterval(start: Fixture.time(1), end: Fixture.time(6)))
        #expect(pieces.map(\.start) == [Fixture.time(1), Fixture.time(3), Fixture.time(5)])
        #expect(pieces.map(\.end) == [Fixture.time(2), Fixture.time(4), Fixture.time(6)])
    }
}
