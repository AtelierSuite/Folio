import Foundation
import Testing
@testable import Planner

struct CalendarAppLinkTests {
    @Test func singleEventLinksByIdentifier() {
        let event = Fixtures.event(local: "ABC-123", start: Fixtures.date(2026, 10, 29, hour: 9))
        #expect(CalendarAppLink.url(for: event)?.absoluteString == "ical://ekevent/ABC-123?method=show&options=more")
    }

    @Test func recurringEventLinksToOccurrence() {
        let start = Fixtures.date(2026, 10, 29, hour: 9).addingTimeInterval(30 * 60)
        let event = CalendarEvent(
            reference: Fixtures.reference(local: "ABC-123"),
            calendarIdentifier: "calendar-1",
            title: "Standup",
            startDate: start,
            endDate: start.addingTimeInterval(900),
            isRecurring: true
        )
        #expect(
            CalendarAppLink.url(for: event)?.absoluteString
                == "ical://ekevent/20261029T093000Z/ABC-123?method=show&options=more"
        )
    }
}
