import Foundation
import Testing
@testable import Planner

@MainActor
struct ReminderIntentActionsTests {
    private let source: FakeCalendarDataSource
    private let actions: ReminderIntentActions

    init() throws {
        source = FakeCalendarDataSource(calendars: [
            Fixtures.plannerCalendar("list-1", kind: .reminder),
            Fixtures.plannerCalendar("list-2", kind: .reminder)
        ])
        let store = CalendarStore(source: source, visibilityStorage: try IntentTestSupport.visibilityStorage())
        actions = ReminderIntentActions(store: store, calendar: Fixtures.calendar)
    }

    @Test func createsAReminderInTheDefaultList() async throws {
        let reminder = try await actions.createReminder(NewReminderRequest(title: " Buy milk "))

        #expect(reminder.title == "Buy milk")
        #expect(reminder.listIdentifier == "list-1")
        #expect(reminder.dueDate == nil)
    }

    @Test func aMidnightDueDateMeansJustTheDay() async throws {
        let dayOnly = try await actions.createReminder(
            NewReminderRequest(title: "Pay rent", dueDate: Fixtures.date(2026, 11, 1))
        )
        let timed = try await actions.createReminder(
            NewReminderRequest(
                title: "Call mum", dueDate: Fixtures.date(2026, 11, 1, hour: 18), listIdentifier: "list-2"
            )
        )

        #expect(!dayOnly.hasDueTime)
        #expect(timed.hasDueTime)
        #expect(timed.listIdentifier == "list-2")
    }

    @Test func refusesEmptyTitles() async {
        await #expect(throws: PlannerIntentError.emptyTitle) {
            try await actions.createReminder(NewReminderRequest(title: "  "))
        }
    }

    @Test func editsOnlyTheFieldsGiven() async throws {
        let created = try await actions.createReminder(NewReminderRequest(title: "Buy milk", notes: "Oat"))

        let edited = try await actions.editReminder(
            ReminderEntity(created), with: ReminderChanges(title: "Buy oat milk", listIdentifier: "list-2")
        )

        #expect(edited.title == "Buy oat milk")
        #expect(edited.listIdentifier == "list-2")
        #expect(edited.notes == "Oat")
    }

    @Test func marksRemindersDoneAndNotDone() async throws {
        let created = try await actions.createReminder(NewReminderRequest(title: "Water plants"))

        _ = try await actions.setCompleted(true, for: ReminderEntity(created))
        #expect(source.completedReminderIdentifiers[created.id] == true)
        _ = try await actions.setCompleted(false, for: ReminderEntity(created))
        #expect(source.completedReminderIdentifiers[created.id] == false)
    }

    @Test func deletesTheReminderAndReportsOnesThatAreGone() async throws {
        let created = try await actions.createReminder(NewReminderRequest(title: "Water plants"))

        try await actions.deleteReminder(ReminderEntity(created))

        #expect(source.storedReminders.isEmpty)
        await #expect(throws: PlannerIntentError.reminderNotFound) {
            try await actions.deleteReminder(ReminderEntity(created))
        }
    }
}
