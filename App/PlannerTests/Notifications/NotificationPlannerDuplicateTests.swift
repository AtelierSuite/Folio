import Foundation
import Testing
@testable import Planner

struct NotificationPlannerDuplicateTests {
    private let now = NotificationFixtures.now
    private let start = NotificationFixtures.hours(2)

    private func copy(
        _ local: String,
        calendarIdentifier: String,
        alarms: [CalendarAlarm] = [.relative(offset: -600)]
    ) -> CalendarEvent {
        NotificationFixtures.event(
            local, start: start, alarms: alarms, title: "Team Sync", calendarIdentifier: calendarIdentifier
        )
    }

    @Test func copiesOfAnEventAlertOnce() {
        let plan = NotificationFixtures.planner().plan(
            events: [copy("first", calendarIdentifier: "work"), copy("second", calendarIdentifier: "home")],
            reminders: [], after: now, budget: .max
        )
        #expect(plan.count == 1)
    }

    @Test func copiesStartingMinutesApartAlertOnceForTheSameLeadTime() {
        let later = NotificationFixtures.event(
            "second", start: start.addingTimeInterval(900), title: "Team Sync", calendarIdentifier: "home"
        )
        let plan = NotificationFixtures.planner().plan(
            events: [copy("first", calendarIdentifier: "work"), later],
            reminders: [], after: now, budget: .max
        )
        #expect(plan.count == 1)
    }

    @Test func differentLeadTimesLandingOnTheSameMomentAlertOnce() {
        let later = NotificationFixtures.event(
            "second", start: start.addingTimeInterval(600), alarms: [.relative(offset: -1200)],
            title: "Team Sync", calendarIdentifier: "home"
        )
        let plan = NotificationFixtures.planner().plan(
            events: [copy("first", calendarIdentifier: "work"), later],
            reminders: [], after: now, budget: .max
        )
        #expect(plan.count == 1)
    }

    @Test func alertsSetOnOnlyOneCopyStillFire() {
        let plan = NotificationFixtures.planner().plan(
            events: [
                copy("first", calendarIdentifier: "work", alarms: [.relative(offset: -600)]),
                copy("second", calendarIdentifier: "home", alarms: [.relative(offset: -600), .relative(offset: -3600)])
            ],
            reminders: [], after: now, budget: .max
        )
        #expect(plan.map(\.fireDate) == [start.addingTimeInterval(-3600), start.addingTimeInterval(-600)])
    }

    @Test func theLoudestStyleAmongCopiesIsKept() {
        var planner = NotificationFixtures.planner()
        planner.styleResolver = { $0.reference.calendarIdentifier == "home" ? .alarm : .standard }
        let plan = planner.plan(
            events: [copy("first", calendarIdentifier: "work"), copy("second", calendarIdentifier: "home")],
            reminders: [], after: now, budget: .max
        )
        #expect(plan.map(\.style) == [.alarm])
    }

    @Test func differentEventsAtTheSameMomentBothAlert() {
        let plan = NotificationFixtures.planner().plan(
            events: [
                NotificationFixtures.event("first", start: start, title: "Standup"),
                NotificationFixtures.event("second", start: start, title: "Review")
            ],
            reminders: [], after: now, budget: .max
        )
        #expect(plan.count == 2)
    }

    @Test func collapsedCopiesLeaveTheBudgetForOtherAlerts() {
        let later = NotificationFixtures.event("later", start: NotificationFixtures.hours(5))
        let plan = NotificationFixtures.planner().plan(
            events: [copy("first", calendarIdentifier: "work"), copy("second", calendarIdentifier: "home"), later],
            reminders: [], after: now, budget: 2
        )
        #expect(plan.map(\.reference.title) == ["Team Sync", "later"])
    }

    @Test func sameNamedRemindersAtTheSameMomentAlertOnce() {
        let due = NotificationFixtures.hours(3)
        let plan = NotificationFixtures.planner().plan(
            events: [],
            reminders: [
                NotificationFixtures.reminder("first", due: due, title: "Pay rent"),
                NotificationFixtures.reminder("second", due: due, title: "pay rent")
            ],
            after: now, budget: .max
        )
        #expect(plan.count == 1)
    }

    @Test func sameNamedRemindersAtDifferentMomentsBothAlert() {
        let plan = NotificationFixtures.planner().plan(
            events: [],
            reminders: [
                NotificationFixtures.reminder("first", due: NotificationFixtures.hours(3), title: "Pay rent"),
                NotificationFixtures.reminder("second", due: NotificationFixtures.hours(4), title: "Pay rent")
            ],
            after: now, budget: .max
        )
        #expect(plan.count == 2)
    }

    @Test func untitledRemindersAreNotDuplicatesOfEachOther() {
        let due = NotificationFixtures.hours(3)
        let plan = NotificationFixtures.planner().plan(
            events: [],
            reminders: [
                NotificationFixtures.reminder("first", due: due, title: ""),
                NotificationFixtures.reminder("second", due: due, title: "")
            ],
            after: now, budget: .max
        )
        #expect(plan.count == 2)
    }
}
