import Foundation
import Testing
@testable import Planner

struct CalendarAccountGroupTests {
    private func calendar(
        _ identifier: String,
        source: String,
        kind: CalendarItemKind = .event
    ) -> PlannerCalendar {
        PlannerCalendar(
            id: identifier,
            title: identifier,
            kind: kind,
            color: .gray,
            sourceIdentifier: source,
            sourceTitle: "Title \(source)",
            sourceType: .calDAV,
            isReadOnly: false
        )
    }

    @Test func groupsCalendarsByAccountInFirstSeenOrder() {
        let groups = CalendarAccountGroup.groups(from: [
            calendar("work", source: "google"),
            calendar("home", source: "icloud"),
            calendar("team", source: "google")
        ])
        #expect(groups.map(\.id) == ["google", "icloud"])
        #expect(groups.map(\.title) == ["Title google", "Title icloud"])
        #expect(groups[0].calendars.map(\.id) == ["work", "team"])
        #expect(groups[1].calendars.map(\.id) == ["home"])
    }

    @Test func emptyInputHasNoGroups() {
        #expect(CalendarAccountGroup.groups(from: []).isEmpty)
        #expect(CalendarAccountGroup.groups(calendars: [], lists: []).isEmpty)
    }

    @Test func listsCalendarsBeforeReminderListsInEachAccount() {
        let groups = CalendarAccountGroup.groups(
            calendars: [
                calendar("work", source: "icloud"),
                calendar("home", source: "google")
            ],
            lists: [
                calendar("groceries", source: "icloud", kind: .reminder),
                calendar("tasks", source: "exchange", kind: .reminder)
            ]
        )
        #expect(groups.map(\.id) == ["icloud", "google", "exchange"])
        #expect(groups[0].calendars.map(\.id) == ["work", "groceries"])
        #expect(groups[0].calendars.map(\.kind) == [.event, .reminder])
        #expect(groups[1].calendars.map(\.id) == ["home"])
        #expect(groups[2].calendars.map(\.id) == ["tasks"])
    }
}
