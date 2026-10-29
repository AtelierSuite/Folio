import Foundation
import Testing
@testable import Planner

struct WidgetSnapshotTests {
    private let now = Fixtures.date(2026, 10, 29, hour: 10)

    private var events: [CalendarEvent] {
        [
            Fixtures.event(local: "breakfast", start: Fixtures.date(2026, 10, 29, hour: 7)),
            Fixtures.event(local: "standup", start: Fixtures.date(2026, 10, 29, hour: 9), hours: 1.5),
            Fixtures.event(local: "lunch", start: Fixtures.date(2026, 10, 29, hour: 12)),
            Fixtures.event(local: "review", start: Fixtures.date(2026, 10, 29, hour: 15)),
            Fixtures.event(local: "tomorrow", start: Fixtures.date(2026, 10, 30, hour: 9))
        ]
    }

    @Test func upNextPrefersTheOngoingEvent() throws {
        let upNext = try #require(WidgetSnapshot(events: events).upNext(at: now))
        #expect(upNext.event.title == "standup")
        #expect(upNext.isOngoing)
        #expect(upNext.following.map(\.title) == ["lunch", "review"])
    }

    @Test func upNextLooksAheadToTomorrow() throws {
        let upNext = try #require(WidgetSnapshot(events: events).upNext(at: Fixtures.date(2026, 10, 29, hour: 20)))
        #expect(upNext.event.title == "tomorrow")
        #expect(!upNext.isOngoing)
        #expect(upNext.following.isEmpty)
        #expect(WidgetSnapshot(events: []).upNext(at: now) == nil)
    }

    @Test func upNextFindsTheJoinLink() throws {
        let meeting = CalendarEvent(
            reference: Fixtures.reference(),
            calendarIdentifier: "calendar-1",
            title: "Sync",
            location: "Room 4",
            notes: "Join at https://meet.example.com/abc today",
            startDate: Fixtures.date(2026, 10, 29, hour: 11),
            endDate: Fixtures.date(2026, 10, 29, hour: 12)
        )
        let upNext = try #require(WidgetSnapshot(events: [meeting]).upNext(at: now))
        #expect(upNext.joinURL == URL(string: "https://meet.example.com/abc"))
    }

    @Test func todayShowsAllDayThenRemainingTimedEvents() {
        let holiday = CalendarEvent(
            reference: Fixtures.reference(local: "holiday"),
            calendarIdentifier: "calendar-1",
            title: "holiday",
            startDate: Fixtures.date(2026, 10, 29),
            endDate: Fixtures.date(2026, 10, 30),
            isAllDay: true
        )
        let snapshot = WidgetSnapshot(events: events + [holiday])
        #expect(snapshot.todayEvents(at: now, calendar: Fixtures.calendar).map(\.title)
            == ["holiday", "standup", "lunch", "review"])
    }

    @Test func todayRemindersIncludeOverdueAndSkipCompletedAndLater() {
        let completed = ReminderItem(
            reference: Fixtures.reference(local: "done"),
            listIdentifier: "list-1",
            title: "done",
            dueDate: Fixtures.date(2026, 10, 29, hour: 8),
            isCompleted: true
        )
        let snapshot = WidgetSnapshot(reminders: [
            Fixtures.reminder(local: "today", due: Fixtures.date(2026, 10, 29, hour: 17)),
            Fixtures.reminder(local: "overdue", due: Fixtures.date(2026, 10, 27, hour: 9)),
            Fixtures.reminder(local: "next week", due: Fixtures.date(2026, 11, 5)),
            Fixtures.reminder(local: "someday", due: nil),
            completed
        ])
        #expect(snapshot.todayReminders(at: now, calendar: Fixtures.calendar).map(\.title) == ["overdue", "today"])
        #expect(snapshot.remainingReminderCount(at: now, calendar: Fixtures.calendar) == 2)
    }

    @Test func checklistListsDatedRemindersFirstThenByPriority() {
        let urgent = ReminderItem(reference: Fixtures.reference(local: "b"), listIdentifier: "list-1", title: "b", priority: 1)
        let plain = ReminderItem(reference: Fixtures.reference(local: "a"), listIdentifier: "list-1", title: "a")
        let snapshot = WidgetSnapshot(reminders: [
            plain,
            urgent,
            Fixtures.reminder(local: "later", due: Fixtures.date(2026, 10, 31)),
            Fixtures.reminder(local: "sooner", due: Fixtures.date(2026, 10, 30))
        ])
        #expect(snapshot.checklist(limit: 10).map(\.title) == ["sooner", "later", "b", "a"])
        #expect(snapshot.checklist(limit: 2).map(\.title) == ["sooner", "later"])
    }

    @Test func monthMarksDaysWithEvents() {
        let grid = MonthGrid(containing: now, calendar: Fixtures.calendar)
        let days = WidgetSnapshot(events: events).daysWithEvents(in: grid)
        #expect(days == [Fixtures.date(2026, 10, 29), Fixtures.date(2026, 10, 30)])
    }
}
