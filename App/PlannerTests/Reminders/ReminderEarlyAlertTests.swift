import Foundation
import Testing
@testable import Planner

struct ReminderEarlyAlertTests {
    private let now = NotificationFixtures.now

    private func planner(
        alerts: [ReminderEarlyAlert],
        allDayMinutes: Int? = 8 * 60
    ) -> NotificationPlanner {
        NotificationPlanner(
            formatter: NotificationFixtures.formatter,
            allDayAlertMinutes: { _ in allDayMinutes },
            reminderEarlyAlerts: { _ in alerts }
        )
    }

    private func makeSettings() throws -> ReminderEarlyAlertSettings {
        let defaults = try #require(UserDefaults(suiteName: "ReminderEarlyAlertTests.\(UUID().uuidString)"))
        return ReminderEarlyAlertSettings(defaults: defaults)
    }

    @Test(arguments: [
        (ReminderEarlyAlert(count: 90, unit: .minutes), Fixtures.date(2026, 12, 15, hour: 7).addingTimeInterval(1800)),
        (ReminderEarlyAlert(count: 3, unit: .hours), Fixtures.date(2026, 12, 15, hour: 6)),
        (ReminderEarlyAlert(count: 2, unit: .days), Fixtures.date(2026, 12, 13, hour: 9)),
        (ReminderEarlyAlert(count: 2, unit: .weeks), Fixtures.date(2026, 12, 1, hour: 9)),
        (ReminderEarlyAlert(count: 1, unit: .months), Fixtures.date(2026, 11, 15, hour: 9))
    ])
    func firesEachUnitBeforeTheDueDate(alert: ReminderEarlyAlert, expected: Date) {
        let fireDate = alert.fireDate(before: Fixtures.date(2026, 12, 15, hour: 9), in: Fixtures.calendar)
        #expect(fireDate == expected)
    }

    @Test func monthsLandOnTheLastDayOfShorterMonths() {
        let alert = ReminderEarlyAlert(count: 1, unit: .months)
        let fireDate = alert.fireDate(before: Fixtures.date(2027, 3, 31, hour: 9), in: Fixtures.calendar)
        #expect(fireDate == Fixtures.date(2027, 2, 28, hour: 9))
    }

    @Test func countsStayWithinTheirRange() {
        var alert = ReminderEarlyAlert(count: 0, unit: .days)
        #expect(alert.count == 1)
        alert.count = 5000
        #expect(alert.count == ReminderEarlyAlert.countRange.upperBound)
    }

    @Test func plansAlongsideTheDueAlarm() {
        let due = Fixtures.date(2026, 11, 10, hour: 9)
        let reminder = NotificationFixtures.reminder("trip", due: due, alarms: [.relative(offset: 0)])
        let plan = planner(alerts: [ReminderEarlyAlert(count: 3, unit: .days)])
            .plan(events: [], reminders: [reminder], after: now, budget: 60)
        #expect(plan.map(\.fireDate) == [Fixtures.date(2026, 11, 7, hour: 9), due])
    }

    @Test func dateOnlyRemindersCountBackFromTheAllDayAlertTime() {
        let reminder = NotificationFixtures.reminder(
            "bill", due: Fixtures.date(2026, 11, 10), hasDueTime: false, alarms: []
        )
        let plan = planner(alerts: [ReminderEarlyAlert(count: 1, unit: .weeks)], allDayMinutes: 7 * 60)
            .plan(events: [], reminders: [reminder], after: now, budget: 60)
        #expect(plan.map(\.fireDate) == [Fixtures.date(2026, 11, 3, hour: 7)])
    }

    @Test func skipsPastAlertsCompletedRemindersAndRemindersWithoutADueDate() {
        let alert = ReminderEarlyAlert(count: 1, unit: .days)
        let reminders = [
            NotificationFixtures.reminder("past", due: NotificationFixtures.hours(2), alarms: []),
            NotificationFixtures.reminder("done", due: NotificationFixtures.hours(48), alarms: [], isCompleted: true),
            NotificationFixtures.reminder("undated", due: nil, alarms: [])
        ]
        let plan = planner(alerts: [alert]).plan(events: [], reminders: reminders, after: now, budget: 60)
        #expect(plan.isEmpty)
    }

    @Test func anAlertMatchingAnAlarmFiresOnce() {
        let due = NotificationFixtures.hours(48)
        let reminder = NotificationFixtures.reminder("match", due: due, alarms: [.relative(offset: -86400)])
        let plan = planner(alerts: [ReminderEarlyAlert(count: 1, unit: .days)])
            .plan(events: [], reminders: [reminder], after: now, budget: 60)
        #expect(plan.map(\.fireDate) == [due.addingTimeInterval(-86400)])
    }

    @Test func settingsFollowTheReminderAcrossTitleAndDueDateChanges() throws {
        let settings = try makeSettings()
        let created = Fixtures.reference(external: nil, local: "reminder", title: "Before")
        let alerts = [ReminderEarlyAlert(count: 2, unit: .months)]
        settings.setAlerts(alerts + alerts, for: created)
        let edited = Fixtures.reference(
            external: "external", local: "reminder", calendarIdentifier: "list-2", title: "After",
            start: Fixtures.date(2026, 12, 1)
        )
        #expect(settings.alerts(for: edited) == alerts)
    }

    @Test func settingsDoNotReachAnotherReminderWithTheSameTitle() throws {
        let settings = try makeSettings()
        let start = Fixtures.date(2026, 12, 1)
        let first = Fixtures.reference(external: nil, local: "first", title: "Same", start: start)
        let second = Fixtures.reference(external: nil, local: "second", title: "Same", start: start)
        settings.setAlerts([.standard], for: first)
        #expect(settings.alerts(for: second).isEmpty)
    }

    @Test func clearingAlertsRemovesThem() throws {
        let settings = try makeSettings()
        let reference = Fixtures.reference(local: "reminder", calendarIdentifier: "list-1", title: "Reminder")
        settings.setAlerts([.standard], for: reference)
        settings.setAlerts([], for: reference)
        #expect(settings.alerts(for: reference).isEmpty)
    }
}
