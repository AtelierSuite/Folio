import Foundation
import Testing
@testable import Planner

struct TimelineLayoutPageTests {
    typealias Support = TimelineTestSupport

    private let layout = Support.engine(startingOn: Support.date(2026, 10, 26), count: 7).layout([
        Support.entry("standup", from: Support.date(2026, 10, 27, 9), to: Support.date(2026, 10, 27, 10)),
        Support.entry("review", from: Support.date(2026, 10, 28, 9), to: Support.date(2026, 10, 28, 11)),
        Support.entry("pairing", from: Support.date(2026, 10, 28, 10), to: Support.date(2026, 10, 28, 12)),
        Support.entry("trip", from: Support.date(2026, 10, 26), to: Support.date(2026, 10, 30), isAllDay: true),
        Support.entry("holiday", from: Support.date(2026, 10, 31), to: Support.date(2026, 11, 1), isAllDay: true)
    ])

    @Test func timedPlacementsAreReindexedFromThePageStart() {
        let page = layout.page(2..<3)
        #expect(page.days.count == 1)
        #expect(page.days.intervals[0].start == Support.date(2026, 10, 28))
        #expect(page.timedPlacements.map(\.entry.id).sorted() == ["pairing", "review"])
        #expect(page.timedPlacements.allSatisfy { $0.dayIndex == 0 })
        #expect(page.timedPlacements.map(\.columnCount) == [2, 2])
    }

    @Test func allDayPlacementsAreClippedAndContinue() {
        let page = layout.page(2..<4)
        #expect(page.allDayPlacements.count == 1)
        let trip = page.allDayPlacements[0]
        #expect((trip.firstDayIndex, trip.lastDayIndex) == (0, 1))
        #expect(trip.continuesFromBefore && !trip.continuesAfter)
    }

    @Test func allDayLanesArePackedPerPage() {
        let overlapping = Support.engine(startingOn: Support.date(2026, 10, 26), count: 7).layout([
            Support.entry("trip", from: Support.date(2026, 10, 26), to: Support.date(2026, 10, 28), isAllDay: true),
            Support.entry("offsite", from: Support.date(2026, 10, 27), to: Support.date(2026, 10, 30), isAllDay: true)
        ])
        #expect(overlapping.allDayLaneCount == 2)
        let page = overlapping.page(2..<4)
        #expect(page.allDayLaneCount == 1)
        #expect(page.allDayPlacements[0].continuesFromBefore)
    }

    @Test func rangePastTheEndIsClamped() {
        let page = layout.page(5..<12)
        #expect(page.days.count == 2)
        #expect(page.allDayPlacements.map(\.entry.id) == ["holiday"])
        #expect(page.allDayPlacements[0].firstDayIndex == 0)
    }
}
