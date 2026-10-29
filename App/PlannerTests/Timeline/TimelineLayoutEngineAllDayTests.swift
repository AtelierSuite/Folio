import Foundation
import Testing
@testable import Planner

struct TimelineLayoutEngineAllDayTests {
    typealias Support = TimelineTestSupport

    private func allDay(_ id: String, from start: Date, to end: Date) -> TimelineEntry {
        Support.entry(id, from: start, to: end, isAllDay: true)
    }

    @Test func multiDayEntrySpansItsDays() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 26), count: 7)
        let layout = engine.layout([
            allDay("conference", from: Support.date(2026, 10, 27), to: Support.date(2026, 10, 30))
        ])
        let placement = layout.allDayPlacements[0]
        #expect((placement.firstDayIndex, placement.lastDayIndex, placement.dayCount) == (1, 3, 3))
        #expect(!placement.continuesFromBefore && !placement.continuesAfter)
        #expect(layout.timedPlacements.isEmpty)
    }

    @Test func eventKitStyleEndOnTheLastDayIsInclusive() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 26), count: 7)
        let layout = engine.layout([
            Support.entry(
                "birthday",
                from: Support.date(2026, 10, 28),
                to: Support.date(2026, 10, 29).addingTimeInterval(-1),
                isAllDay: true
            )
        ])
        #expect(layout.allDayPlacements[0].firstDayIndex == 2)
        #expect(layout.allDayPlacements[0].lastDayIndex == 2)
    }

    @Test func entryIsClippedToTheVisibleDays() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 28), count: 3)
        let layout = engine.layout([
            allDay("trip", from: Support.date(2026, 10, 25), to: Support.date(2026, 11, 5))
        ])
        let placement = layout.allDayPlacements[0]
        #expect((placement.firstDayIndex, placement.lastDayIndex) == (0, 2))
        #expect(placement.continuesFromBefore && placement.continuesAfter)
    }

    @Test func entryOutsideTheVisibleDaysIsDropped() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 28), count: 1)
        let layout = engine.layout([
            allDay("yesterday", from: Support.date(2026, 10, 27), to: Support.date(2026, 10, 28))
        ])
        #expect(layout.allDayPlacements.isEmpty)
        #expect(layout.allDayLaneCount == 0)
    }

    @Test func overlappingEntriesStackIntoLanes() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 26), count: 7)
        let layout = engine.layout([
            allDay("holiday", from: Support.date(2026, 10, 28), to: Support.date(2026, 10, 29)),
            allDay("conference", from: Support.date(2026, 10, 27), to: Support.date(2026, 10, 30)),
            allDay("weekend", from: Support.date(2026, 10, 31), to: Support.date(2026, 11, 2))
        ])
        let lanes = Dictionary(uniqueKeysWithValues: layout.allDayPlacements.map { ($0.entry.id, $0.lane) })
        #expect(lanes == ["conference": 0, "holiday": 1, "weekend": 0])
        #expect(layout.allDayLaneCount == 2)
    }

    @Test func floatingAllDayEntryKeepsItsDate() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 26), count: 7)
        let layout = engine.layout([
            Support.entry(
                "tokyoHoliday",
                from: Support.date(2026, 10, 28, in: Support.tokyo),
                to: Support.date(2026, 10, 29, in: Support.tokyo),
                isAllDay: true,
                timeZone: nil
            )
        ])
        #expect(layout.allDayPlacements[0].firstDayIndex == 2)
        #expect(layout.allDayPlacements[0].lastDayIndex == 2)
    }

    @Test func allDayEntryOverDaylightSavingKeepsWholeDays() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 31), count: 3)
        let layout = engine.layout([
            allDay("longWeekend", from: Support.date(2026, 10, 31), to: Support.date(2026, 11, 3))
        ])
        let placement = layout.allDayPlacements[0]
        #expect((placement.firstDayIndex, placement.lastDayIndex) == (0, 2))
        #expect(!placement.continuesAfter)
    }

    @Test func zeroLengthAllDayEntryCoversItsDay() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 28), count: 2)
        let layout = engine.layout([
            allDay("marker", from: Support.date(2026, 10, 29), to: Support.date(2026, 10, 29))
        ])
        #expect(layout.allDayPlacements[0].firstDayIndex == 1)
        #expect(layout.allDayPlacements[0].lastDayIndex == 1)
    }
}
