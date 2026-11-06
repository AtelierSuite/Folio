import Foundation
import Testing
@testable import Planner

struct WidgetDayLoadTests {
    private func date(hour: Int, minute: Int = 0) -> Date {
        Fixtures.date(2026, 11, 6, hour: hour).addingTimeInterval(Double(minute) * 60)
    }

    private func load(_ events: [CalendarEvent], travel: [DateInterval] = [], at now: Date) -> WidgetDayLoad {
        WidgetDayLoad(events: events, travel: travel, at: now, calendar: Fixtures.calendar)
    }

    @Test func isFreeUntilTheNextEvent() {
        let dayLoad = load([Fixtures.event(local: "dentist", start: date(hour: 14))], at: date(hour: 13))
        #expect(dayLoad.status == .free(until: date(hour: 14)))
    }

    @Test func travelCountsAsBusy() {
        let travel = DateInterval(start: date(hour: 13, minute: 30), end: date(hour: 14))
        let dayLoad = load([Fixtures.event(local: "dentist", start: date(hour: 14))], travel: [travel], at: date(hour: 13))
        #expect(dayLoad.status == .free(until: date(hour: 13, minute: 30)))
    }

    @Test func overlappingEventsCountOnce() {
        let events = [
            Fixtures.event(local: "planning", start: date(hour: 16)),
            Fixtures.event(local: "vendor", start: date(hour: 16, minute: 30))
        ]
        let dayLoad = load(events, at: date(hour: 16, minute: 10))
        #expect(dayLoad.status == .busy(until: date(hour: 17, minute: 30)))
        #expect(dayLoad.busyIntervals.count == 1)
    }

    @Test func dropsGapsThatAreTooShort() {
        let events = [
            Fixtures.event(local: "first", start: date(hour: 9)),
            Fixtures.event(local: "second", start: date(hour: 10, minute: 10))
        ]
        let dayLoad = load(events, at: date(hour: 9, minute: 30))
        #expect(dayLoad.gaps.first?.start == date(hour: 11, minute: 10))
    }

    @Test func ignoresAllDayAndDeclinedEvents() {
        let allDay = CalendarEvent(
            reference: Fixtures.reference(local: "holiday"),
            calendarIdentifier: "calendar-1",
            title: "Holiday",
            startDate: date(hour: 0),
            endDate: date(hour: 23),
            isAllDay: true
        )
        let declined = CalendarEvent(
            reference: Fixtures.reference(local: "declined"),
            calendarIdentifier: "calendar-1",
            title: "Declined",
            startDate: date(hour: 12),
            endDate: date(hour: 13),
            userStatus: .declined
        )
        #expect(load([allDay, declined], at: date(hour: 10)).status == .free(until: date(hour: 22)))
    }

    @Test func dayIsOverAfterTheWindow() {
        let dayLoad = load([], at: date(hour: 23))
        #expect(dayLoad.status == .dayOver)
        #expect(dayLoad.gaps.isEmpty)
    }

    @Test func gapsStartAtTheWindowBeforeTheDayBegins() {
        #expect(load([], at: date(hour: 6)).gaps.first?.start == date(hour: 8))
    }
}
