import Foundation
import Testing
@testable import Planner

struct SearchIndexTests {
    private let documents = [
        SearchDocument(event: SearchFixtures.event("Design review", location: "Room Café")),
        SearchDocument(event: SearchFixtures.event("Quarterly planning", notes: "Bring the roadmap")),
        SearchDocument(reminder: SearchFixtures.reminder("Buy oat milk")),
        SearchFixtures.note("Trip", text: "---\ntags: [travel]\n---\n定例会議のメモ and packing list")
    ]

    private func titles(_ text: String, in index: SearchIndex) -> [String] {
        index.search(SearchQuery(text: text)).map(\.title).sorted()
    }

    @Test func matchesWordPrefixesInTitlesLocationsAndBodies() {
        let index = SearchFixtures.index(documents)
        #expect(titles("rev", in: index) == ["Design review"])
        #expect(titles("road", in: index) == ["Quarterly planning"])
        #expect(titles("cafe", in: index) == ["Design review"])
        #expect(titles("OAT", in: index) == ["Buy oat milk"])
        #expect(titles("view", in: index).isEmpty)
    }

    @Test func requiresEveryTermToMatch() {
        let index = SearchFixtures.index(documents)
        #expect(titles("design room", in: index) == ["Design review"])
        #expect(titles("design milk", in: index).isEmpty)
    }

    @Test func matchesInsideWordsForScriptsWithoutSpaces() {
        let index = SearchFixtures.index(documents)
        #expect(titles("会議", in: index) == ["Trip"])
        #expect(titles("travel", in: index) == ["Trip"])
    }

    @Test func emptyTextOnlyMatchesWithANarrowingFilter() {
        let index = SearchFixtures.index(documents)
        #expect(index.search(SearchQuery()).isEmpty)
        #expect(index.search(SearchQuery(kinds: [.reminder])).isEmpty)
        let interval = DateInterval(start: Fixtures.date(2026, 10, 29), end: Fixtures.date(2026, 10, 30))
        #expect(index.search(SearchQuery(dateInterval: interval)).count == 2)
    }

    @Test func replacingAndRemovingDocumentsUpdatesTheVocabulary() {
        var index = SearchFixtures.index(documents)
        let renamed = SearchDocument(event: SearchFixtures.event("Design critique", local: "Design review"))
        index.apply(upserting: [renamed], removing: [])
        #expect(titles("review", in: index).isEmpty)
        #expect(titles("critique", in: index) == ["Design critique"])
        #expect(!index.sortedTokens.contains("review"))

        index.apply(upserting: [], removing: [renamed.id])
        #expect(titles("design", in: index).isEmpty)
        #expect(index.count == documents.count - 1)
    }

    @Test func resultsAreChronological() {
        let index = SearchFixtures.index([
            SearchDocument(event: SearchFixtures.event("Sync B", start: Fixtures.date(2026, 11, 2, hour: 9))),
            SearchDocument(event: SearchFixtures.event("Sync A", start: Fixtures.date(2026, 10, 2, hour: 9))),
            SearchDocument(reminder: SearchFixtures.reminder("Sync notes"))
        ])
        #expect(index.search(SearchQuery(text: "sync")).map(\.title) == ["Sync A", "Sync B", "Sync notes"])
    }
}
