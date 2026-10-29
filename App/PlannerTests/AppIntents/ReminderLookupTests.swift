import Foundation
import Testing
@testable import Planner

struct ReminderLookupTests {
    private let now = IntentTestSupport.now

    private func lookup(_ reminders: [ReminderItem], hiding hidden: Set<String> = []) throws -> ReminderLookup {
        ReminderLookup(
            source: FakeCalendarDataSource(reminders: reminders),
            visibilityStorage: try IntentTestSupport.visibilityStorage(hiding: hidden)
        )
    }

    private func reminder(
        _ title: String,
        due: Date? = nil,
        isCompleted: Bool = false,
        list: String = "list-1"
    ) -> ReminderItem {
        ReminderItem(
            reference: Fixtures.reference(
                external: "external-\(title)", local: title, calendarIdentifier: list, title: title
            ),
            listIdentifier: list,
            title: title,
            dueDate: due,
            isCompleted: isCompleted
        )
    }

    @Test func findsAReminderByItsStorageKey() async throws {
        let milk = reminder("Buy milk")
        let lookup = try lookup([reminder("Call mum"), milk])

        #expect(await lookup.reminders(withIdentifiers: [milk.reference.storageKey], now: now) == [milk])
        #expect(ReminderEntity(milk).id == "external-Buy milk")
    }

    @Test func matchesTitlesWordByWordWithOpenRemindersFirst() async throws {
        let done = reminder("Pay rent", isCompleted: true)
        let open = reminder("Pay electricity bill", due: Fixtures.date(2026, 11, 1))
        let lookup = try lookup([done, open, reminder("Water plants")])

        #expect(await lookup.reminders(matching: "pay", now: now) == [open, done])
        #expect(await lookup.reminders(matching: "electricity bill", now: now) == [open])
    }

    @Test func suggestsOpenVisibleRemindersSoonestDueFirst() async throws {
        let later = reminder("Later", due: Fixtures.date(2026, 11, 5))
        let soon = reminder("Soon", due: Fixtures.date(2026, 10, 30))
        let undated = reminder("Someday")
        let hidden = reminder("Hidden", due: Fixtures.date(2026, 10, 29), list: "hidden")
        let lookup = try lookup([later, undated, reminder("Done", isCompleted: true), soon, hidden], hiding: ["hidden"])

        #expect(await lookup.suggestedReminders(now: now) == [soon, later, undated])
    }
}
