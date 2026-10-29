import Foundation
import Testing
@testable import Planner

@MainActor
struct SearchPerformanceTests {
    private static let words = [
        "standup", "review", "planning", "retro", "lunch", "interview", "offsite", "sync", "demo", "budget",
        "hiring", "roadmap", "design", "launch", "workshop", "training", "dentist", "gym", "flight", "dinner"
    ]

    private static func largeCalendar(eventCount: Int) -> [CalendarEvent] {
        let start = Fixtures.date(2024, 11, 1, hour: 8)
        return (0..<eventCount).map { number in
            let first = words[number % words.count]
            let second = words[(number / words.count) % words.count]
            return SearchFixtures.event(
                "\(first.capitalized) \(second) \(number)",
                local: "event-\(number)",
                calendarIdentifier: "calendar-\(number % 8)",
                start: start.addingTimeInterval(Double(number) * 3600 * 2),
                location: "Room \(number % 40)",
                notes: number.isMultiple(of: 5) ? "Join https://meet.example.com/\(number)" : "Agenda item \(number)"
            )
        }
    }

    @Test func searchesALargeCalendarQuickly() async throws {
        let events = Self.largeCalendar(eventCount: 12_000)
        let source = FakeCalendarDataSource(events: events)
        let defaults = try #require(UserDefaults(suiteName: "SearchPerformanceTests.\(UUID().uuidString)"))
        let indexer = SearchIndexer(
            source: source,
            storage: SearchRangeStorage(defaults: defaults),
            calendar: Fixtures.calendar,
            now: { Fixtures.date(2026, 10, 29) }
        )
        let clock = ContinuousClock()
        let indexingTime = await clock.measure { await indexer.activate() }
        #expect(await indexer.catalog.count == events.count)
        #expect(indexingTime < .seconds(10))

        let query = SearchQuery(text: "plan room 1", requiresMeetingLink: true)
        var results: [SearchDocument] = []
        let queryTime = await clock.measure { results = await indexer.search(query) }
        #expect(!results.isEmpty)
        #expect(results.allSatisfy { $0.title.hasPrefix("Planning") || $0.title.contains(" planning ") })
        #expect(queryTime < .milliseconds(250))

        let broadQueryTime = await clock.measure { results = await indexer.search(SearchQuery(text: "s")) }
        #expect(results.count > 1000)
        #expect(broadQueryTime < .seconds(1))

        let reindexTime = await clock.measure { await indexer.reindexCalendar() }
        #expect(reindexTime < indexingTime + .seconds(1))
    }
}
