import Foundation
import Testing
@testable import Planner

struct PlannerCalendarBirthdaysTests {
    private func calendar(_ identifier: String, sourceType: CalendarSourceType) -> PlannerCalendar {
        PlannerCalendar(
            id: identifier,
            title: identifier,
            kind: .event,
            color: .gray,
            sourceIdentifier: identifier,
            sourceTitle: identifier,
            sourceType: sourceType,
            isReadOnly: sourceType == .birthdays
        )
    }

    @Test func findsTheBirthdaysCalendar() {
        let calendars = [calendar("work", sourceType: .calDAV), calendar("birthdays", sourceType: .birthdays)]
        #expect(calendars.birthdayCalendar?.id == "birthdays")
    }

    @Test func leavesBirthdaysOutOfAccounts() {
        let calendars = [
            calendar("work", sourceType: .calDAV),
            calendar("birthdays", sourceType: .birthdays),
            calendar("home", sourceType: .local)
        ]
        #expect(calendars.excludingBirthdays.map(\.id) == ["work", "home"])
    }

    @Test func hasNoBirthdaysCalendarWhenContactsBirthdaysAreOff() {
        #expect([calendar("work", sourceType: .calDAV)].birthdayCalendar == nil)
    }
}
