import Foundation
import Testing
@testable import Planner

struct ReminderDraftTests {
    private let due = Fixtures.date(2026, 10, 29, hour: 9)

    @Test func draftFromReminderCopiesEditableFields() {
        let recurrence = ReminderRecurrence(frequency: .weekly, interval: 2)
        let reminder = ReminderItem(
            reference: Fixtures.reference(local: "milk"),
            listIdentifier: "list-1",
            title: "Milk",
            notes: "Oat",
            dueDate: due,
            hasDueTime: true,
            priority: 5,
            url: URL(string: "https://example.com"),
            alarms: [.absolute(due), .relative(-900)],
            recurrence: recurrence
        )
        let draft = ReminderDraft(reminder)
        #expect(draft.title == "Milk")
        #expect(draft.notes == "Oat")
        #expect(draft.priority == .medium)
        #expect(draft.recurrence == recurrence)
        #expect(draft.alarms == [.relative(0), .relative(-900)])
        #expect(draft.url?.host() == "example.com")
    }

    @Test func eventKitPrioritiesMapToBuckets() {
        #expect(ReminderPriority(eventKitPriority: 0) == .none)
        #expect(ReminderPriority(eventKitPriority: 3) == .high)
        #expect(ReminderPriority(eventKitPriority: 5) == .medium)
        #expect(ReminderPriority(eventKitPriority: 7) == .low)
    }

    @Test func validationRequiresTitleAndList() {
        #expect(!ReminderDraft(title: "  ", listIdentifier: "list-1").isValid)
        #expect(!ReminderDraft(title: "Milk", listIdentifier: "").isValid)
        #expect(ReminderDraft(title: "Milk", listIdentifier: "list-1").isValid)
    }

    @Test func normalizingWithoutDueDateDropsScheduleDependentFields() {
        let draft = ReminderDraft(
            title: "  Milk \n",
            listIdentifier: "list-1",
            hasDueTime: true,
            recurrence: ReminderRecurrence(frequency: .daily),
            alarms: [.relative(-300), .absolute(due), .absolute(due)],
            notes: " \n"
        ).normalized()
        #expect(draft.title == "Milk")
        #expect(draft.notes.isEmpty)
        #expect(!draft.hasDueTime)
        #expect(draft.recurrence == nil)
        #expect(draft.alarms == [.absolute(due)])
    }

    @Test func dateOnlyDueDateDropsRelativeAlarmsButKeepsRecurrence() {
        let draft = ReminderDraft(
            title: "Milk",
            listIdentifier: "list-1",
            dueDate: due,
            recurrence: ReminderRecurrence(frequency: .monthly),
            alarms: [.relative(0)]
        ).normalized()
        #expect(draft.alarms.isEmpty)
        #expect(draft.recurrence?.frequency == .monthly)
    }

    @Test func dueDateComponentsIncludeTimeOnlyWhenRequested() {
        var draft = ReminderDraft(title: "Milk", listIdentifier: "list-1", dueDate: due)
        let dateOnly = draft.dueDateComponents(in: Fixtures.calendar)
        #expect(dateOnly?.day == 29)
        #expect(dateOnly?.hour == nil)
        draft.hasDueTime = true
        let timed = draft.dueDateComponents(in: Fixtures.calendar)
        #expect(timed?.hour == 9)
        #expect(timed?.minute == 0)
    }

    @Test func relativeAlarmFireDateFollowsDueDate() {
        #expect(ReminderAlarm.relative(-3600).fireDate(dueDate: due) == Fixtures.date(2026, 10, 29, hour: 8))
        #expect(ReminderAlarm.relative(-3600).fireDate(dueDate: nil) == nil)
        #expect(ReminderAlarm.absolute(due).fireDate(dueDate: nil) == due)
    }

    @Test func recurrenceIntervalIsAtLeastOne() {
        #expect(ReminderRecurrence(frequency: .daily, interval: 0).interval == 1)
    }

    @Test func urlParsingAddsSchemeWhenMissing() {
        #expect(ReminderDraft.parsedURL(from: " ") == nil)
        #expect(ReminderDraft.parsedURL(from: "example.com")?.absoluteString == "https://example.com")
        #expect(ReminderDraft.parsedURL(from: "folio://note")?.scheme == "folio")
    }
}

struct ReminderDraftScheduleTests {
    @Test func togglingDueDateClearsDependentFields() {
        var draft = ReminderDraft(listIdentifier: "list-1")
        draft.setHasDueDate(true, defaultDate: Fixtures.date(2026, 10, 29, hour: 15), calendar: Fixtures.calendar)
        #expect(draft.dueDate == Fixtures.date(2026, 10, 29))
        draft.recurrence = ReminderRecurrence(frequency: .daily)
        draft.setHasDueDate(false, defaultDate: .now, calendar: Fixtures.calendar)
        #expect(draft.dueDate == nil)
        #expect(draft.recurrence == nil)
    }

    @Test func enablingTimeUsesNextHourOnDueDay() {
        var draft = ReminderDraft(listIdentifier: "list-1", dueDate: Fixtures.date(2026, 11, 2))
        draft.setHasDueTime(true, now: Fixtures.date(2026, 10, 29, hour: 14), calendar: Fixtures.calendar)
        #expect(draft.dueDate == Fixtures.date(2026, 11, 2, hour: 15))
        #expect(draft.hasDueTime)
        draft.alarms = [.relative(0), .absolute(Fixtures.date(2026, 11, 1))]
        draft.setHasDueTime(false, calendar: Fixtures.calendar)
        #expect(draft.dueDate == Fixtures.date(2026, 11, 2))
        #expect(draft.alarms == [.absolute(Fixtures.date(2026, 11, 1))])
    }
}
