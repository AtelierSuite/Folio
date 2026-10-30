import Foundation
import Testing
@testable import Planner

struct ReminderListContentsTests {
    private let startOfToday = Fixtures.date(2026, 10, 29)

    private func reminder(
        _ title: String,
        listIdentifier: String = "list-1",
        due: Date? = nil,
        completedOn completionDate: Date? = nil
    ) -> ReminderItem {
        ReminderItem(
            reference: Fixtures.reference(
                external: "external-\(title)", local: title, calendarIdentifier: listIdentifier
            ),
            listIdentifier: listIdentifier,
            title: title,
            dueDate: due,
            isCompleted: completionDate != nil,
            completionDate: completionDate
        )
    }

    @Test func listsOnlyTheRequestedList() {
        let reminders = [reminder("Mine"), reminder("Other", listIdentifier: "list-2")]
        let contents = ReminderListContents.reminders(from: reminders, inList: "list-1", completedSince: startOfToday)
        #expect(contents.map(\.title) == ["Mine"])
    }

    @Test func ordersByDueDateThenUndatedThenTodaysCompletions() {
        let reminders = [
            reminder("Done today", completedOn: Fixtures.date(2026, 10, 29, hour: 9)),
            reminder("Done last week", completedOn: Fixtures.date(2026, 10, 20)),
            reminder("Undated"),
            reminder("Later", due: Fixtures.date(2026, 11, 2)),
            reminder("Sooner", due: Fixtures.date(2026, 10, 30))
        ]
        let contents = ReminderListContents.reminders(from: reminders, inList: "list-1", completedSince: startOfToday)
        #expect(contents.map(\.title) == ["Sooner", "Later", "Undated", "Done today"])
    }

    @Test func countsOnlyOpenReminders() {
        let reminders = [
            reminder("Open"),
            reminder("Also open", due: Fixtures.date(2026, 10, 30)),
            reminder("Done", completedOn: Fixtures.date(2026, 10, 29, hour: 9)),
            reminder("Elsewhere", listIdentifier: "list-2")
        ]
        #expect(ReminderListContents.openCounts(from: reminders) == ["list-1": 2, "list-2": 1])
    }
}
