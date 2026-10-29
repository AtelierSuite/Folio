import Foundation
import Testing
@testable import Planner

struct CalendarDeepLinkTests {
    @Test func dayLinksRoundTrip() {
        let url = CalendarDeepLink.url(forDay: Fixtures.date(2026, 10, 29, hour: 15), calendar: Fixtures.calendar)
        #expect(url.absoluteString == "folio://day/2026-10-29")
        #expect(CalendarDeepLink.destination(from: url, calendar: Fixtures.calendar) == .calendarDay(Fixtures.date(2026, 10, 29)))
    }

    @Test func eventLinksCarryTheReference() throws {
        let occurrence = Fixtures.date(2026, 10, 29, hour: 9)
        let event = CalendarEvent(
            reference: Fixtures.reference(external: "ext/1", local: "ABC:123/x", occurrence: occurrence, title: "Stand up & sync"),
            calendarIdentifier: "calendar-1",
            title: "Stand up & sync",
            startDate: occurrence,
            endDate: occurrence.addingTimeInterval(3_600)
        )
        let url = CalendarDeepLink.url(for: event)
        let destination = try #require(CalendarDeepLink.destination(from: url))
        guard case .calendarDay(let date, let item) = destination, let item else {
            Issue.record("Expected an event destination, got \(destination)")
            return
        }
        #expect(date == occurrence)
        #expect(item.matchScore(against: event.reference) != nil)
        #expect(item.localIdentifier == "ABC:123/x")
        #expect(item.externalIdentifier == "ext/1")
        #expect(item.occurrenceDate == occurrence)
        #expect(item.title == "Stand up & sync")
    }

    @Test func composerLinks() {
        #expect(CalendarDeepLink.destination(from: CalendarDeepLink.url(forNew: .event)) == .newEvent)
        #expect(CalendarDeepLink.destination(from: CalendarDeepLink.url(forNew: .reminder)) == .newReminder)
        #expect(CalendarDeepLink.destination(from: CalendarDeepLink.url(forNew: .note)) == .newNote)
    }

    @Test func ignoresUnknownLinks() throws {
        for string in ["folio://note/abc", "folio://day/tomorrow", "folio://event/abc", "https://day/2026-10-29", "folio://new/task"] {
            #expect(CalendarDeepLink.destination(from: try #require(URL(string: string))) == nil)
        }
    }
}
