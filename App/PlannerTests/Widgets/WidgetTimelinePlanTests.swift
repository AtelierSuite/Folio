import Foundation
import Testing
@testable import Planner

struct WidgetTimelinePlanTests {
    private let now = Fixtures.date(2026, 10, 29, hour: 8)

    @Test func entriesChangeAtEachEventStartAndEnd() {
        let events = [
            Fixtures.event(local: "standup", start: Fixtures.date(2026, 10, 29, hour: 9)),
            Fixtures.event(local: "review", start: Fixtures.date(2026, 10, 29, hour: 11), hours: 2)
        ]
        let plan = WidgetTimelinePlan(events: events, from: now, calendar: Fixtures.calendar)
        #expect(plan.entryDates == [
            now,
            Fixtures.date(2026, 10, 29, hour: 9),
            Fixtures.date(2026, 10, 29, hour: 10),
            Fixtures.date(2026, 10, 29, hour: 11),
            Fixtures.date(2026, 10, 29, hour: 13),
            Fixtures.date(2026, 10, 29, hour: 14)
        ])
        #expect(plan.reloadDate == Fixtures.date(2026, 10, 29, hour: 14))
    }

    @Test func skipsPastBoundariesAllDayEventsAndDuplicates() {
        var allDay = Fixtures.event(local: "holiday", start: Fixtures.date(2026, 10, 29), hours: 24)
        allDay = CalendarEvent(
            reference: allDay.reference,
            calendarIdentifier: allDay.calendarIdentifier,
            title: allDay.title,
            startDate: allDay.startDate,
            endDate: allDay.endDate,
            isAllDay: true
        )
        let events = [
            allDay,
            Fixtures.event(local: "breakfast", start: Fixtures.date(2026, 10, 29, hour: 7), hours: 2),
            Fixtures.event(local: "standup", start: Fixtures.date(2026, 10, 29, hour: 9))
        ]
        let plan = WidgetTimelinePlan(events: events, from: now, calendar: Fixtures.calendar)
        #expect(plan.entryDates == [
            now,
            Fixtures.date(2026, 10, 29, hour: 9),
            Fixtures.date(2026, 10, 29, hour: 10),
            Fixtures.date(2026, 10, 29, hour: 14)
        ])
    }

    @Test func endsAtMidnightWhenItComesFirst() {
        let lateNow = Fixtures.date(2026, 10, 29, hour: 22)
        let events = [Fixtures.event(local: "late", start: Fixtures.date(2026, 10, 29, hour: 23), hours: 2)]
        let plan = WidgetTimelinePlan(events: events, from: lateNow, calendar: Fixtures.calendar)
        #expect(plan.entryDates == [lateNow, Fixtures.date(2026, 10, 29, hour: 23), Fixtures.date(2026, 10, 30)])
        #expect(plan.reloadDate == Fixtures.date(2026, 10, 30))
    }

    @Test func capsEntriesAndReloadsAfterTheLastOne() {
        let events = (0..<10).map { index in
            Fixtures.event(local: "slot-\(index)", start: now.addingTimeInterval(Double(index + 1) * 600), hours: 0.1)
        }
        let plan = WidgetTimelinePlan(events: events, from: now, calendar: Fixtures.calendar, entryLimit: 5)
        #expect(plan.entryDates.count == 5)
        #expect(plan.reloadDate == plan.entryDates.last)
    }
}
