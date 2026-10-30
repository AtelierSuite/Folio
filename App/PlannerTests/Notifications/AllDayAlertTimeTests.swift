import Foundation
import Testing
@testable import Planner

struct AllDayAlertTimeTests {
    private let now = NotificationFixtures.now
    private let day = Fixtures.date(2026, 10, 31)

    private func planner(minutes: [String: Int]) -> NotificationPlanner {
        NotificationPlanner(
            formatter: NotificationFixtures.formatter,
            allDayAlertMinutes: { minutes[$0] }
        )
    }

    private func allDay(alarms: [CalendarAlarm], calendarIdentifier: String = "calendar-1") -> CalendarEvent {
        NotificationFixtures.event(
            "holiday", start: day, hours: 24, alarms: alarms, isAllDay: true, calendarIdentifier: calendarIdentifier
        )
    }

    @Test func relativeAlertsKeepTheirDayButUseTheCalendarTime() {
        let event = allDay(alarms: [.relative(offset: -15 * 3600), .relative(offset: 9 * 3600)])
        let plan = planner(minutes: ["calendar-1": 7 * 60 + 30])
            .plan(events: [event], reminders: [], after: now, budget: 60)
        #expect(plan.map(\.fireDate) == [
            Fixtures.date(2026, 10, 30, hour: 7).addingTimeInterval(30 * 60),
            Fixtures.date(2026, 10, 31, hour: 7).addingTimeInterval(30 * 60)
        ])
    }

    @Test func alertsOnTheSameDayCollapseIntoOne() {
        let event = allDay(alarms: [.relative(offset: 0), .relative(offset: 9 * 3600)])
        let plan = planner(minutes: ["calendar-1": 8 * 60])
            .plan(events: [event], reminders: [], after: now, budget: 60)
        #expect(plan.map(\.fireDate) == [Fixtures.date(2026, 10, 31, hour: 8)])
    }

    @Test func absoluteAlertsAndTimedEventsAreUntouched() {
        let absolute = Fixtures.date(2026, 10, 30, hour: 21)
        let allDayEvent = allDay(alarms: [.absolute(date: absolute)])
        let timed = NotificationFixtures.event("meeting", start: NotificationFixtures.hours(2))
        let plan = planner(minutes: ["calendar-1": 8 * 60])
            .plan(events: [allDayEvent, timed], reminders: [], after: now, budget: 60)
        #expect(plan.map(\.fireDate) == [NotificationFixtures.hours(2).addingTimeInterval(-600), absolute])
    }

    @Test func settingsDefaultToEightAndStoreOnlyChanges() throws {
        let defaults = try #require(UserDefaults(suiteName: "AllDayAlertTimeTests.\(UUID().uuidString)"))
        let settings = AllDayAlertTimeSettings(defaults: defaults)
        #expect(settings.minutesAfterMidnight(forCalendar: "work") == 8 * 60)
        settings.setMinutesAfterMidnight(6 * 60 + 45, forCalendar: "work")
        #expect(settings.minutesAfterMidnight(forCalendar: "work") == 6 * 60 + 45)
        #expect(settings.minutesAfterMidnight(forCalendar: "home") == 8 * 60)
        settings.setMinutesAfterMidnight(8 * 60, forCalendar: "work")
        #expect(defaults.dictionary(forKey: AllDayAlertTimeSettings.calendarTimesKey)?.isEmpty == true)
    }
}
