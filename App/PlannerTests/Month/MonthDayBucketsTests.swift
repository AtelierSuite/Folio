import Foundation
import Testing
@testable import Planner

struct MonthDayBucketsTests {
    typealias Support = MonthTestSupport

    private let grid = Support.grid(2026, 10)

    private func items(on year: Int, _ month: Int, _ day: Int, in buckets: MonthDayBuckets) -> [MonthDayItem] {
        guard let monthDay = grid.day(containing: Support.date(year, month, day, 12)) else { return [] }
        return buckets.items(on: monthDay)
    }

    @Test func timedEventLandsOnItsDay() {
        let event = Support.entry("lunch", from: Support.date(2026, 10, 14, 12), to: Support.date(2026, 10, 14, 13))
        let buckets = MonthDayBuckets(grid: grid, entries: [event])
        #expect(items(on: 2026, 10, 14, in: buckets).map(\.id) == ["lunch"])
        #expect(items(on: 2026, 10, 15, in: buckets).isEmpty)
    }

    @Test func multiDayAllDayEventFillsEveryDay() {
        let trip = Support.entry(
            "trip", from: Support.date(2026, 10, 20), to: Support.date(2026, 10, 23), isAllDay: true
        )
        let buckets = MonthDayBuckets(grid: grid, entries: [trip])
        let covered = grid.days.filter { !buckets.items(on: $0).isEmpty }.map(\.dayOfMonth)
        #expect(covered == [20, 21, 22])
        let first = items(on: 2026, 10, 20, in: buckets)[0]
        #expect(!first.continuesFromPreviousDay && first.continuesToNextDay)
        let last = items(on: 2026, 10, 22, in: buckets)[0]
        #expect(last.continuesFromPreviousDay && !last.continuesToNextDay)
    }

    @Test func timedEventEndingAtMidnightStaysOnOneDay() {
        let event = Support.entry("late", from: Support.date(2026, 10, 14, 22), to: Support.date(2026, 10, 15))
        let buckets = MonthDayBuckets(grid: grid, entries: [event])
        #expect(items(on: 2026, 10, 14, in: buckets).count == 1)
        #expect(items(on: 2026, 10, 15, in: buckets).isEmpty)
        #expect(!items(on: 2026, 10, 14, in: buckets)[0].isSpanning)
    }

    @Test func overnightTimedEventSpansBothDays() {
        let event = Support.entry("flight", from: Support.date(2026, 10, 14, 22), to: Support.date(2026, 10, 15, 6))
        let buckets = MonthDayBuckets(grid: grid, entries: [event])
        #expect(items(on: 2026, 10, 14, in: buckets)[0].continuesToNextDay)
        #expect(items(on: 2026, 10, 15, in: buckets)[0].continuesFromPreviousDay)
    }

    @Test func remindersLandOnTheirDueDay() throws {
        let due = Support.date(2026, 10, 20, 9)
        let reminder = try #require(TimelineEntry(
            reminder: Fixtures.reminder(local: "pay", due: due), calendar: Support.calendar()
        ))
        let undated = TimelineEntry(reminder: Fixtures.reminder(local: "someday", due: nil))
        let buckets = MonthDayBuckets(grid: grid, entries: [reminder] + [undated].compactMap(\.self))
        #expect(items(on: 2026, 10, 20, in: buckets).map(\.entry.kind) == [.reminder])
        #expect(grid.days.map { buckets.items(on: $0).count }.reduce(0, +) == 1)
    }

    @Test func entriesOutsideTheGridAreDropped() {
        let event = Support.entry("old", from: Support.date(2026, 8, 1, 9), to: Support.date(2026, 8, 1, 10))
        let buckets = MonthDayBuckets(grid: grid, entries: [event])
        #expect(grid.days.allSatisfy { buckets.items(on: $0).isEmpty })
    }

    @Test func spanningItemsComeBeforeTimedItems() {
        let entries = [
            Support.entry("morning", from: Support.date(2026, 10, 14, 8), to: Support.date(2026, 10, 14, 9)),
            Support.entry(
                "errand", from: Support.date(2026, 10, 14), to: Support.date(2026, 10, 15),
                isAllDay: true, kind: .reminder
            ),
            Support.entry("early", from: Support.date(2026, 10, 14, 7), to: Support.date(2026, 10, 14, 8)),
            Support.entry("holiday", from: Support.date(2026, 10, 14), to: Support.date(2026, 10, 15), isAllDay: true),
            Support.entry("week", from: Support.date(2026, 10, 12), to: Support.date(2026, 10, 17), isAllDay: true)
        ]
        let buckets = MonthDayBuckets(grid: grid, entries: entries)
        #expect(items(on: 2026, 10, 14, in: buckets).map(\.id) == ["week", "holiday", "errand", "early", "morning"])
    }

    @Test func instantEventLandsOnOneDay() {
        let event = Support.entry("ping", from: Support.date(2026, 10, 15), to: Support.date(2026, 10, 15))
        let buckets = MonthDayBuckets(grid: grid, entries: [event])
        #expect(items(on: 2026, 10, 15, in: buckets).count == 1)
        #expect(items(on: 2026, 10, 14, in: buckets).isEmpty)
    }
}
