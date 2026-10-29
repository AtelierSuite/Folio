import Foundation
import Testing
@testable import Planner

struct ReminderInboxTests {
    private let startOfToday = Fixtures.date(2026, 10, 29)

    private func undated(_ title: String, completedOn completionDate: Date? = nil) -> ReminderItem {
        ReminderItem(
            reference: Fixtures.reference(external: "external-\(title)", local: title, calendarIdentifier: "list-1"),
            listIdentifier: "list-1",
            title: title,
            isCompleted: completionDate != nil,
            completionDate: completionDate
        )
    }

    @Test func listsOnlyUndatedReminders() {
        let dated = Fixtures.reminder(local: "dated", due: Fixtures.date(2026, 10, 29))
        let inbox = ReminderInbox.reminders(from: [dated, undated("Plan trip")], completedSince: startOfToday)
        #expect(inbox.map(\.title) == ["Plan trip"])
    }

    @Test func keepsTodaysCompletionsAfterOpenRemindersAndDropsOlderOnes() {
        let reminders = [
            undated("Done today", completedOn: Fixtures.date(2026, 10, 29, hour: 9)),
            undated("Done last week", completedOn: Fixtures.date(2026, 10, 20)),
            undated("item 10"),
            undated("item 2")
        ]
        let inbox = ReminderInbox.reminders(from: reminders, completedSince: startOfToday)
        #expect(inbox.map(\.title) == ["item 2", "item 10", "Done today"])
    }
}
