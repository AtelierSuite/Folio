import Foundation
import Testing
@testable import Planner

struct TimelineLayoutMinimumHeightTests {
    typealias Support = TimelineTestSupport

    private let layout = Support.engine(startingOn: Support.date(2026, 11, 18), count: 1).layout([
        Support.entry("dose", from: Support.date(2026, 11, 18, 8), to: Support.date(2026, 11, 18, 8)),
        Support.entry("packing", from: Support.date(2026, 11, 18, 8, 15), to: Support.date(2026, 11, 18, 8, 45)),
        Support.entry("standup", from: Support.date(2026, 11, 18, 10), to: Support.date(2026, 11, 18, 11))
    ])

    @Test func backToBackEntriesShareAColumnAtTheirOwnHeight() {
        #expect(layout.timedPlacements.allSatisfy { $0.columnCount == 1 })
    }

    @Test func entriesDrawnTallerThanTheirDurationGetTheirOwnColumns() {
        let fitted = layout.fittingCards(minimumHours: 0.5)
        let columns = Dictionary(uniqueKeysWithValues: fitted.timedPlacements.map { ($0.entry.id, $0.column) })
        #expect(columns["dose"] == 0)
        #expect(columns["packing"] == 1)
        #expect(fitted.timedPlacements.first { $0.entry.id == "standup" }?.columnCount == 1)
    }

    @Test func layoutIsUnchangedWhenEveryEntryIsTallEnough() {
        #expect(layout.fittingCards(minimumHours: 0.25) == layout)
    }
}
