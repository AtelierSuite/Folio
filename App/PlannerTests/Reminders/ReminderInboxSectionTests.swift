import Foundation
import Testing
@testable import Planner

struct ReminderInboxSectionTests {
    private func list(_ identifier: String) -> PlannerCalendar {
        PlannerCalendar(
            id: identifier,
            title: "Title \(identifier)",
            kind: .reminder,
            color: .gray,
            sourceIdentifier: "icloud",
            sourceTitle: "iCloud",
            sourceType: .calDAV,
            isReadOnly: false
        )
    }

    private func undated(_ title: String, in listIdentifier: String) -> ReminderItem {
        ReminderItem(
            reference: Fixtures.reference(
                external: "external-\(title)", local: title, calendarIdentifier: listIdentifier
            ),
            listIdentifier: listIdentifier,
            title: title
        )
    }

    @Test func groupsRemindersByListInListOrderKeepingReminderOrder() {
        let reminders = [
            undated("Buy milk", in: "groceries"),
            undated("Call bank", in: "home"),
            undated("Eggs", in: "groceries")
        ]
        let sections = ReminderInbox.sections(
            from: reminders, lists: [list("home"), list("work"), list("groceries")]
        )
        #expect(sections.map(\.id) == ["home", "groceries"])
        #expect(sections.map { $0.list?.title } == ["Title home", "Title groceries"])
        #expect(sections[1].reminders.map(\.title) == ["Buy milk", "Eggs"])
    }

    @Test func putsRemindersInUnknownListsLast() {
        let sections = ReminderInbox.sections(
            from: [undated("Orphan", in: "gone"), undated("Call bank", in: "home")],
            lists: [list("home")]
        )
        #expect(sections.map(\.id) == ["home", "gone"])
        #expect(sections[1].list == nil)
    }
}
