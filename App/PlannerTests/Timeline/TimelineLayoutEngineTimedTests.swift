import Foundation
import Testing
@testable import Planner

struct TimelineLayoutEngineTimedTests {
    typealias Support = TimelineTestSupport

    @Test func overlappingEventsGetColumns() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 28), count: 1)
        let layout = engine.layout([
            Support.entry("review", from: Support.date(2026, 10, 28, 10), to: Support.date(2026, 10, 28, 11)),
            Support.entry("oneOnOne", from: Support.date(2026, 10, 28, 10, 30), to: Support.date(2026, 10, 28, 11, 30)),
            Support.entry("lunch", from: Support.date(2026, 10, 28, 12), to: Support.date(2026, 10, 28, 13))
        ])
        let placements = Dictionary(uniqueKeysWithValues: layout.timedPlacements.map { ($0.entry.id, $0) })
        #expect(placements["review"]?.leadingFraction == 0)
        #expect(placements["review"]?.widthFraction == 0.5)
        #expect(placements["oneOnOne"]?.leadingFraction == 0.5)
        #expect(placements["lunch"]?.widthFraction == 1)
        #expect(placements["lunch"]?.startHour == 12)
        #expect(placements["lunch"]?.endHour == 13)
    }

    @Test func midnightCrossingEventIsSplitAcrossDays() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 28), count: 2)
        let layout = engine.layout([
            Support.entry("flight", from: Support.date(2026, 10, 28, 22), to: Support.date(2026, 10, 29, 2, 30))
        ])
        #expect(layout.timedPlacements.count == 2)
        let first = layout.timedPlacements[0]
        let second = layout.timedPlacements[1]
        #expect((first.dayIndex, first.startHour, first.endHour) == (0, 22, 24))
        #expect(first.continuesToNextDay && !first.continuesFromPreviousDay)
        #expect((second.dayIndex, second.startHour, second.endHour) == (1, 0, 2.5))
        #expect(second.continuesFromPreviousDay && !second.continuesToNextDay)
        #expect(first.id != second.id)
    }

    @Test func eventOutsideTheVisibleDaysIsDropped() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 28), count: 1)
        let layout = engine.layout([
            Support.entry("tomorrow", from: Support.date(2026, 10, 29, 9), to: Support.date(2026, 10, 29, 10))
        ])
        #expect(layout.timedPlacements.isEmpty)
    }

    @Test func shortEventsGetTheMinimumHeightAndOverlap() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 28), count: 1)
        let layout = engine.layout([
            Support.entry("ping", from: Support.date(2026, 10, 28, 9), to: Support.date(2026, 10, 28, 9, 5)),
            Support.entry("next", from: Support.date(2026, 10, 28, 9, 10), to: Support.date(2026, 10, 28, 9, 30))
        ])
        #expect(layout.timedPlacements[0].endHour == 9.25)
        #expect(layout.timedPlacements.allSatisfy { $0.columnCount == 2 })
    }

    @Test func shortEventAtTheEndOfTheDayStaysInsideIt() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 28), count: 1)
        let layout = engine.layout([
            Support.entry("late", from: Support.date(2026, 10, 28, 23, 55), to: Support.date(2026, 10, 28, 23, 58))
        ])
        #expect(layout.timedPlacements[0].startHour == 23.75)
        #expect(layout.timedPlacements[0].endHour == 24)
    }

    @Test func zonedEventMovesWithTheDisplayTimeZone() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 28), count: 1)
        let tokyoMorning = Support.date(2026, 10, 29, 9, in: Support.tokyo)
        let call = Support.entry(
            "call", from: tokyoMorning, to: tokyoMorning.addingTimeInterval(3600), timeZone: Support.tokyo
        )
        let layout = engine.layout([call])
        #expect(layout.timedPlacements[0].startHour == 20)
    }

    @Test func floatingEventKeepsItsClockTime() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 28), count: 1)
        let sevenInTokyo = Support.date(2026, 10, 28, 7, in: Support.tokyo)
        let run = Support.entry("run", from: sevenInTokyo, to: sevenInTokyo.addingTimeInterval(1800), timeZone: nil)
        let layout = engine.layout([run])
        #expect(layout.timedPlacements[0].dayIndex == 0)
        #expect(layout.timedPlacements[0].startHour == 7)
        #expect(layout.timedPlacements[0].endHour == 7.5)
    }

    @Test func eventsAfterSpringForwardKeepTheirClockTime() {
        let engine = Support.engine(startingOn: Support.date(2026, 3, 8), count: 1)
        let layout = engine.layout([
            Support.entry("brunch", from: Support.date(2026, 3, 8, 11), to: Support.date(2026, 3, 8, 12, 30))
        ])
        #expect(layout.timedPlacements[0].startHour == 11)
        #expect(layout.timedPlacements[0].endHour == 12.5)
    }

    @Test func eventsInTheRepeatedHourOverlap() {
        let engine = Support.engine(startingOn: Support.date(2026, 11, 1), count: 1)
        let firstOneAM = Support.date(2026, 11, 1, 1)
        let secondOneAM = firstOneAM.addingTimeInterval(3600)
        let layout = engine.layout([
            Support.entry("first", from: firstOneAM, to: firstOneAM.addingTimeInterval(1800)),
            Support.entry("second", from: secondOneAM, to: secondOneAM.addingTimeInterval(1800))
        ])
        #expect(layout.timedPlacements.allSatisfy { $0.startHour == 1 && $0.endHour == 1.5 })
        #expect(Set(layout.timedPlacements.map(\.column)) == [0, 1])
    }

    @Test func eventEndingAfterFallBackStillCoversTheDayToMidnight() {
        let engine = Support.engine(startingOn: Support.date(2026, 11, 1), count: 1)
        let layout = engine.layout([
            Support.entry("evening", from: Support.date(2026, 11, 1, 22), to: Support.date(2026, 11, 2, 1))
        ])
        #expect(layout.timedPlacements[0].endHour == 24)
        #expect(layout.timedPlacements[0].continuesToNextDay)
    }

    @Test func currentTimePositionFollowsTheDays() {
        let engine = Support.engine(startingOn: Support.date(2026, 10, 28), count: 7)
        let position = engine.currentTimePosition(at: Support.date(2026, 10, 30, 14, 15))
        #expect(position == TimelineTimePosition(dayIndex: 2, hour: 14.25))
        #expect(engine.currentTimePosition(at: Support.date(2026, 11, 5)) == nil)
    }
}
