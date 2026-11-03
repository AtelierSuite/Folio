import Foundation
import Testing
@testable import Planner

struct WakeUpAlarmPlannerTests {
    private let now = Fixtures.date(2026, 10, 29, hour: 3)
    private let planner = WakeUpAlarmPlanner(
        leadTime: 90 * 60, earliestMinutes: 6 * 60, latestEventMinutes: 12 * 60, days: 2, calendar: Fixtures.calendar
    )

    private func event(_ local: String, day: Int, hour: Double, isAllDay: Bool = false) -> CalendarEvent {
        let start = Fixtures.date(2026, 10, day).addingTimeInterval(hour * 3600)
        return NotificationFixtures.event(local, start: start, isAllDay: isAllDay)
    }

    @Test func ringsLeadTimeBeforeEachMorningsFirstEvent() {
        let alarms = planner.alarms(for: [
            event("later", day: 29, hour: 10), event("first", day: 29, hour: 9), event("next", day: 30, hour: 8.5)
        ], after: now)
        #expect(alarms.map(\.event.title) == ["first", "next"])
        #expect(alarms.map(\.fireDate) == [
            Fixtures.date(2026, 10, 29).addingTimeInterval(7.5 * 3600),
            Fixtures.date(2026, 10, 30, hour: 7)
        ])
    }

    @Test func skipsHolidays() {
        var holidayPlanner = planner
        holidayPlanner.skippedDays = [HolidayDay(year: 2026, month: 10, day: 29)]
        let alarms = holidayPlanner.alarms(for: [
            event("holiday", day: 29, hour: 9), event("workday", day: 30, hour: 9)
        ], after: now)
        #expect(alarms.map(\.event.title) == ["workday"])
    }

    @Test func neverRingsBeforeTheEarliestTime() {
        let alarms = planner.alarms(for: [event("early", day: 29, hour: 6.5)], after: now)
        #expect(alarms.map(\.fireDate) == [Fixtures.date(2026, 10, 29, hour: 6)])
    }

    @Test func skipsEventsOutsideTheMorningAndAllDayOrDeclinedEvents() {
        let declined = CalendarEvent(
            reference: Fixtures.reference(local: "declined", start: Fixtures.date(2026, 10, 29, hour: 8)),
            calendarIdentifier: "calendar-1",
            title: "declined",
            startDate: Fixtures.date(2026, 10, 29, hour: 8),
            endDate: Fixtures.date(2026, 10, 29, hour: 9),
            userStatus: .declined
        )
        let alarms = planner.alarms(for: [
            declined,
            event("beforeEarliest", day: 29, hour: 5),
            event("allDay", day: 29, hour: 0, isAllDay: true),
            event("afternoon", day: 29, hour: 12),
            event("counted", day: 29, hour: 11)
        ], after: now)
        #expect(alarms.map(\.event.title) == ["counted"])
    }

    @Test func dropsAlarmsThatAlreadyRang() {
        let later = Fixtures.date(2026, 10, 29, hour: 8)
        #expect(planner.alarms(for: [event("standup", day: 29, hour: 9)], after: later).isEmpty)
    }

    @Test func coversTodayPlusTheNextDays() {
        let interval = planner.interval(after: now)
        #expect(interval.start == Fixtures.date(2026, 10, 29))
        #expect(interval.end == Fixtures.date(2026, 11, 1))
    }
}
