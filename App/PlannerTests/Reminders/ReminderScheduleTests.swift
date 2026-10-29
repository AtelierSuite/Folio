import Foundation
import Testing
@testable import Planner

struct ReminderScheduleTests {
    private let now = Fixtures.date(2026, 10, 29, hour: 12)
    private let today = DateInterval(start: Fixtures.date(2026, 10, 29), end: Fixtures.date(2026, 10, 30))
    private let week = DateInterval(start: Fixtures.date(2026, 10, 26), end: Fixtures.date(2026, 11, 2))

    private func schedule(_ policy: OverdueReminderPolicy) -> ReminderSchedule {
        ReminderSchedule(policy: policy, calendar: Fixtures.calendar, now: now)
    }

    private func completed(_ reminder: ReminderItem, on date: Date) -> ReminderItem {
        ReminderItem(
            reference: reminder.reference,
            listIdentifier: reminder.listIdentifier,
            title: reminder.title,
            dueDate: reminder.dueDate,
            hasDueTime: reminder.hasDueTime,
            isCompleted: true,
            completionDate: date
        )
    }

    @Test func carriesOverdueRemindersForwardToToday() {
        let overdue = Fixtures.reminder(local: "overdue", due: Fixtures.date(2026, 10, 27))
        let dueToday = Fixtures.reminder(local: "today", due: Fixtures.date(2026, 10, 29, hour: 9))
        let shown = schedule(.carryForward).reminders([overdue, dueToday], in: today)
        #expect(shown.map(\.title) == ["overdue", "today"])
        #expect(shown.first?.carriedForwardDate == Fixtures.date(2026, 10, 29))
        #expect(shown.first?.dueDate == Fixtures.date(2026, 10, 27))
        #expect(shown.last?.isCarriedForward == false)
    }

    @Test func carriedRemindersLeaveTheirOriginalDay() {
        let overdue = Fixtures.reminder(local: "overdue", due: Fixtures.date(2026, 10, 27))
        let originalDay = DateInterval(start: Fixtures.date(2026, 10, 27), end: Fixtures.date(2026, 10, 28))
        #expect(schedule(.carryForward).reminders([overdue], in: originalDay).isEmpty)
        #expect(schedule(.carryForward).reminders([overdue], in: week).map(\.scheduledDate) == [
            Fixtures.date(2026, 10, 29)
        ])
    }

    @Test func keepingOnDueDateLeavesOverdueRemindersAlone() {
        let overdue = Fixtures.reminder(local: "overdue", due: Fixtures.date(2026, 10, 27))
        #expect(schedule(.keepOnDueDate).reminders([overdue], in: today).isEmpty)
        let shown = schedule(.keepOnDueDate).reminders([overdue], in: week)
        #expect(shown.map(\.scheduledDate) == [Fixtures.date(2026, 10, 27)])
        #expect(shown.first?.isCarriedForward == false)
    }

    @Test func completedTodayStaysOnTodayButOlderCompletionsStayPut() {
        let reminder = Fixtures.reminder(local: "done", due: Fixtures.date(2026, 10, 27))
        let doneToday = completed(reminder, on: Fixtures.date(2026, 10, 29, hour: 8))
        let doneEarlier = completed(reminder, on: Fixtures.date(2026, 10, 28, hour: 8))
        #expect(schedule(.carryForward).reminders([doneToday], in: today).count == 1)
        #expect(schedule(.carryForward).reminders([doneEarlier], in: today).isEmpty)
        #expect(schedule(.carryForward).reminders([doneEarlier], in: week).map(\.scheduledDate) == [
            Fixtures.date(2026, 10, 27)
        ])
    }

    @Test func futureAndUndatedRemindersAreNotOverdue() {
        let future = Fixtures.reminder(local: "future", due: Fixtures.date(2026, 10, 31))
        let undated = Fixtures.reminder(local: "undated", due: nil)
        #expect(!schedule(.carryForward).isOverdue(future))
        #expect(!schedule(.carryForward).isOverdue(undated))
        #expect(schedule(.carryForward).reminders([future, undated], in: week).map(\.title) == ["future"])
    }

    @Test func carriedTimedReminderBecomesAllDayEntryOnToday() throws {
        let overdue = ReminderItem(
            reference: Fixtures.reference(external: "external-timed", local: "timed", calendarIdentifier: "list-1"),
            listIdentifier: "list-1",
            title: "timed",
            dueDate: Fixtures.date(2026, 10, 27, hour: 15),
            hasDueTime: true
        )
        let carried = try #require(schedule(.carryForward).reminders([overdue], in: today).first)
        let entry = try #require(TimelineEntry(reminder: carried, calendar: Fixtures.calendar))
        #expect(entry.isAllDay)
        #expect(entry.isOverdue)
        #expect(entry.start == Fixtures.date(2026, 10, 29))
        #expect(entry.end == Fixtures.date(2026, 10, 30))
    }
}
