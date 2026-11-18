import Foundation
import Testing
@testable import Planner

struct BirthdayAlertTests {
    private let now = NotificationFixtures.now
    private let day = Fixtures.date(2026, 10, 31)

    private func planner(alarms: [CalendarAlarm]) -> NotificationPlanner {
        NotificationPlanner(
            formatter: NotificationFixtures.formatter,
            allDayAlertMinutes: { _ in 9 * 60 },
            birthdayAlarms: { alarms }
        )
    }

    private func birthday(alarms: [CalendarAlarm] = [], isBirthday: Bool = true) -> CalendarEvent {
        NotificationFixtures.event(
            "birthday", start: day, hours: 24, alarms: alarms, isAllDay: true, isBirthday: isBirthday
        )
    }

    @Test func birthdaysWithoutAlertsUseTheBirthdayAlerts() {
        let plan = planner(alarms: [.relative(offset: 0), .relative(offset: -86400)])
            .plan(events: [birthday()], reminders: [], after: now, budget: 60)
        #expect(plan.map(\.fireDate) == [Fixtures.date(2026, 10, 30, hour: 9), Fixtures.date(2026, 10, 31, hour: 9)])
    }

    @Test func birthdaysKeepTheirOwnAlerts() {
        let plan = planner(alarms: [.relative(offset: -86400)])
            .plan(events: [birthday(alarms: [.relative(offset: 0)])], reminders: [], after: now, budget: 60)
        #expect(plan.map(\.fireDate) == [Fixtures.date(2026, 10, 31, hour: 9)])
    }

    @Test func otherEventsWithoutAlertsStaySilent() {
        let plan = planner(alarms: [.relative(offset: 0)])
            .plan(events: [birthday(isBirthday: false)], reminders: [], after: now, budget: 60)
        #expect(plan.isEmpty)
    }

    @Test func birthdayAlertsAreMarkedAsBirthdays() {
        let alerts = planner(alarms: [.relative(offset: 0)])
        let birthdayPlan = alerts.plan(events: [birthday()], reminders: [], after: now, budget: 60)
        let eventPlan = alerts.plan(
            events: [birthday(alarms: [.relative(offset: 0)], isBirthday: false)], reminders: [], after: now, budget: 60
        )
        #expect(birthdayPlan.map(\.isBirthday) == [true])
        #expect(eventPlan.map(\.isBirthday) == [false])
        #expect(birthdayPlan.map(\.id) != eventPlan.map(\.id))
    }

    @Test func settingsChooseTheDefaultAlerts() throws {
        let defaults = try #require(UserDefaults(suiteName: "BirthdayAlertTests.\(UUID().uuidString)"))
        let settings = BirthdaySettings(defaults: defaults)
        #expect(settings.defaultAlarms == [.relative(offset: 0)])
        settings.alertsDayBefore = true
        #expect(settings.defaultAlarms == [.relative(offset: 0), .relative(offset: -86400)])
        settings.alertsOnTheDay = false
        #expect(settings.defaultAlarms == [.relative(offset: -86400)])
    }
}
