import Foundation
import Testing
@testable import Planner

struct CalendarAccountGroupTests {
    private func calendar(_ identifier: String, source: String) -> PlannerCalendar {
        PlannerCalendar(
            id: identifier,
            title: identifier,
            kind: .event,
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
    }
}
