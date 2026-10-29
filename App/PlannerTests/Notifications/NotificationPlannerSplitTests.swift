import Foundation
import Testing
@testable import Planner

struct NotificationPlannerSplitTests {
    private func planner(alarmCalendars: Set<String>) -> NotificationPlanner {
        NotificationPlanner(formatter: NotificationFixtures.formatter) { candidate in
            alarmCalendars.contains(candidate.reference.calendarIdentifier) ? .alarm : .standard
        }
    }

    private func events(_ count: Int, calendar: String) -> [CalendarEvent] {
        (0..<count).map { index in
            NotificationFixtures.event(
                "\(calendar)-\(index)",
                start: NotificationFixtures.hours(Double(index) + 1),
                calendarIdentifier: calendar
            )
        }
    }

    @Test func alarmsDoNotUseTheNotificationBudget() {
        let plan = planner(alarmCalendars: ["wake"]).plan(
            events: events(5, calendar: "work") + events(3, calendar: "wake"),
            reminders: [],
            after: NotificationFixtures.now,
            budget: 5,
            alarmBudget: 10
        )
        #expect(plan.notifications.count == 5)
        #expect(plan.alarms.map(\.content.title) == ["wake-0", "wake-1", "wake-2"])
        #expect(plan.alarms.allSatisfy { $0.style == .alarm })
    }

    @Test func alarmsHaveTheirOwnCap() {
        let plan = planner(alarmCalendars: ["wake"]).plan(
            events: events(40, calendar: "wake"),
            reminders: [],
            after: NotificationFixtures.now,
            budget: 60,
            alarmBudget: NotificationPlanner.alarmLimit
        )
        #expect(plan.alarms.count == NotificationPlanner.alarmLimit)
        #expect(plan.notifications.isEmpty)
    }

    @Test func withoutAlarmPermissionAlarmsBecomeTimeSensitiveNotifications() {
        let plan = planner(alarmCalendars: ["wake"]).plan(
            events: events(2, calendar: "wake"),
            reminders: [],
            after: NotificationFixtures.now,
            budget: 60,
            alarmBudget: nil
        )
        #expect(plan.alarms.isEmpty)
        #expect(plan.notifications.map(\.style) == [.timeSensitive, .timeSensitive])
    }
}
