import Foundation
import Testing
@testable import Planner

struct TimelineBusyWeekTests {
    typealias Support = TimelineTestSupport

    private func busyWeek() -> [TimelineEntry] {
        (0..<7).flatMap { dayOffset in
            (0..<9).map { slot in
                let start = Support.date(2026, 10, 26 + dayOffset, 8 + slot, slot % 3 * 20)
                let length = Double(30 + slot % 4 * 30) * 60
                return Support.entry("event-\(dayOffset)-\(slot)", from: start, to: start.addingTimeInterval(length))
            }
        }
    }

    @Test func placementsInTheSameColumnNeverOverlap() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 26), count: 7)
        let layout = engine.layout(busyWeek())
        #expect(layout.timedPlacements.count == 63)
        for dayIndex in 0..<7 {
            let placements = layout.timedPlacements(onDay: dayIndex)
            for lhs in placements {
                #expect(lhs.column + lhs.columnSpan <= lhs.columnCount)
                for rhs in placements where lhs.id != rhs.id {
                    let sharesColumn = lhs.column < rhs.column + rhs.columnSpan
                        && rhs.column < lhs.column + lhs.columnSpan
                    let sharesTime = lhs.startHour < rhs.endHour && rhs.startHour < lhs.endHour
                    #expect(!(sharesColumn && sharesTime))
                }
            }
        }
    }

    @Test func layoutIsFastEnoughForEveryFrame() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 26), count: 7)
        let entries = busyWeek()
        let clock = ContinuousClock()
        let elapsed = clock.measure {
            for _ in 0..<20 {
                _ = engine.layout(entries)
            }
        }
        #expect(elapsed < .seconds(1))
    }
}
