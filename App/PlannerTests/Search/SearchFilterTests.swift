import Foundation
import Testing
@testable import Planner

struct SearchFilterTests {
    private let index = SearchFixtures.index([
        SearchDocument(event: SearchFixtures.event(
            "Team sync", calendarIdentifier: "work", start: Fixtures.date(2026, 10, 29, hour: 9),
            notes: "Join at https://meet.google.com/abc-defg-hij"
        )),
        SearchDocument(event: SearchFixtures.event(
            "Family sync", calendarIdentifier: "home", start: Fixtures.date(2026, 12, 24, hour: 18)
        )),
        SearchDocument(event: SearchFixtures.event(
            "Vendor sync", calendarIdentifier: "work", start: Fixtures.date(2026, 11, 3, hour: 9),
            url: URL(string: "https://acme.zoom.us/j/1")
        )),
        SearchDocument(reminder: SearchFixtures.reminder(
            "Sync photos", listIdentifier: "chores", due: Fixtures.date(2026, 10, 29, hour: 12)
        )),
        SearchFixtures.note(
            "Sync ideas", text: "Agenda for the next sync", modified: Fixtures.date(2026, 10, 29, hour: 8)
        )
    ])

    private func titles(_ query: SearchQuery) -> [String] {
        index.search(query).map(\.title).sorted()
    }

    @Test func filtersByKind() {
        #expect(titles(SearchQuery(text: "sync", kinds: [.reminder])) == ["Sync photos"])
        #expect(titles(SearchQuery(text: "sync", kinds: [.note])) == ["Sync ideas"])
        #expect(titles(SearchQuery(text: "sync", kinds: [.event])).count == 3)
    }

    @Test func filtersByCalendarOrListAndDropsNotes() {
        #expect(titles(SearchQuery(text: "sync", containerIdentifiers: ["work"])) == ["Team sync", "Vendor sync"])
        #expect(titles(SearchQuery(text: "sync", containerIdentifiers: ["chores"])) == ["Sync photos"])
    }

    @Test func excludesHiddenCalendars() {
        #expect(!titles(SearchQuery(text: "sync", excludedContainerIdentifiers: ["work"])).contains("Team sync"))
        #expect(titles(SearchQuery(text: "sync", excludedContainerIdentifiers: ["work"])).contains("Sync ideas"))
    }

    @Test func filtersByDateRange() {
        let interval = DateInterval(start: Fixtures.date(2026, 10, 29), end: Fixtures.date(2026, 10, 30))
        #expect(titles(SearchQuery(text: "sync", dateInterval: interval)) == ["Sync ideas", "Sync photos", "Team sync"])
    }

    @Test func dateRangeIncludesEventsOverlappingItsStart() {
        let interval = DateInterval(start: Fixtures.date(2026, 10, 29, hour: 9).addingTimeInterval(1800), duration: 60)
        #expect(titles(SearchQuery(text: "team", dateInterval: interval)) == ["Team sync"])
    }

    @Test func filtersByMeetingLink() {
        #expect(titles(SearchQuery(text: "sync", requiresMeetingLink: true)) == ["Team sync", "Vendor sync"])
        #expect(titles(SearchQuery(kinds: [.event], requiresMeetingLink: true)) == ["Team sync", "Vendor sync"])
    }

    @Test func meetingLinkCheckLooksForKnownProviders() {
        #expect(MeetingLink.isPresent(in: ["Dial in: HTTPS://Meet.Google.com/abc-defg-hij"]))
        #expect(MeetingLink.isPresent(in: [nil], url: URL(string: "https://zoom.us/j/123")))
        #expect(!MeetingLink.isPresent(in: ["Room 4", "https://example.com"], url: URL(string: "mailto:a@example.com")))
    }
}
