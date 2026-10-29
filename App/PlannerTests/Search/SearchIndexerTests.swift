import Foundation
import Synchronization
import Testing
@testable import Planner

@MainActor
struct SearchIndexerTests {
    private let today = Fixtures.date(2026, 10, 29, hour: 12)

    private func makeIndexer(source: FakeCalendarDataSource) throws -> SearchIndexer {
        let defaults = try #require(UserDefaults(suiteName: "SearchIndexerTests.\(UUID().uuidString)"))
        return SearchIndexer(
            source: source,
            storage: SearchRangeStorage(defaults: defaults),
            calendar: Fixtures.calendar,
            now: { [today] in today }
        )
    }

    private func titles(_ text: String, _ indexer: SearchIndexer) async -> [String] {
        await indexer.search(SearchQuery(text: text)).map(\.title).sorted()
    }

    @Test func indexesNothingUntilActivated() async throws {
        let source = FakeCalendarDataSource(events: [SearchFixtures.event("Standup")])
        let indexer = try makeIndexer(source: source)
        await indexer.reindexCalendar()
        #expect(source.eventFetchIntervals.isEmpty)
        #expect(await titles("standup", indexer).isEmpty)

        await indexer.activate()
        #expect(await titles("standup", indexer) == ["Standup"])
        #expect(indexer.revision == 1)
        #expect(!indexer.isIndexing)
    }

    @Test func fetchesTheConfiguredRange() async throws {
        let source = FakeCalendarDataSource(events: [
            SearchFixtures.event("Old offsite", start: Fixtures.date(2024, 9, 1, hour: 9)),
            SearchFixtures.event("Recent offsite", start: Fixtures.date(2025, 1, 10, hour: 9)),
            SearchFixtures.event("Future offsite", start: Fixtures.date(2027, 10, 28, hour: 9)),
            SearchFixtures.event("Far offsite", start: Fixtures.date(2027, 12, 1, hour: 9))
        ])
        let indexer = try makeIndexer(source: source)
        #expect(indexer.range == .default)
        await indexer.activate()
        #expect(source.eventFetchIntervals.first == DateInterval(
            start: Fixtures.date(2024, 10, 29), end: Fixtures.date(2027, 10, 30)
        ))
        #expect(await titles("offsite", indexer) == ["Future offsite", "Recent offsite"])

        await indexer.setRange(SearchRange(monthsBack: 36, monthsAhead: 2))
        #expect(await titles("offsite", indexer) == ["Old offsite", "Recent offsite"])
    }

    @Test func rangeIsPersisted() throws {
        let defaults = try #require(UserDefaults(suiteName: "SearchIndexerTests.\(UUID().uuidString)"))
        let storage = SearchRangeStorage(defaults: defaults)
        storage.range = SearchRange(monthsBack: 6, monthsAhead: 3)
        #expect(SearchIndexer(source: FakeCalendarDataSource(), storage: storage).range.monthsBack == 6)
    }

    @Test func calendarChangesUpdateTheIndexIncrementally() async throws {
        let source = FakeCalendarDataSource(
            events: [SearchFixtures.event("Standup"), SearchFixtures.event("Retro", start: today)],
            reminders: [SearchFixtures.reminder("Water plants")]
        )
        let indexer = try makeIndexer(source: source)
        await indexer.activate()

        source.replaceEvents([SearchFixtures.event("Standup"), SearchFixtures.event("Retrospective", local: "Retro")])
        source.state.withLock { $0.reminders = [SearchFixtures.reminder("Water garden", due: today)] }
        await indexer.reindexCalendar()

        #expect(await titles("retro", indexer) == ["Retrospective"])
        #expect(await titles("water", indexer) == ["Water garden"])
        #expect(await titles("plants", indexer).isEmpty)
        #expect(await indexer.catalog.count == 3)
    }

    @Test func notesAreReadAgainOnlyWhenTheyChange() async throws {
        let directory = try TemporaryDirectory()
        let store = NoteFileStore(rootURL: directory.url)
        try directory.write("Pack the tent", to: "Camping.md")
        try directory.write("Call the plumber", to: "Home/Chores.md")
        let indexer = try makeIndexer(source: FakeCalendarDataSource())
        await indexer.activate()
        await indexer.updateNotes(try await store.notes())
        #expect(await titles("tent", indexer) == ["Camping"])
        #expect(await titles("plumber", indexer) == ["Chores"])

        try directory.write("Pack the stove", to: "Camping.md")
        let camping = directory.url.appending(path: "Camping.md")
        try FileManager.default.setAttributes(
            [.modificationDate: Date.now.addingTimeInterval(60)], ofItemAtPath: camping.path(percentEncoded: false)
        )
        try FileManager.default.removeItem(at: directory.url.appending(path: "Home/Chores.md"))
        let files = try await store.notes()
        #expect(await indexer.catalog.notesNeedingIndexing(in: files).map(\.title) == ["Camping"])
        await indexer.updateNotes(files)

        #expect(await titles("stove", indexer) == ["Camping"])
        #expect(await titles("tent", indexer).isEmpty)
        #expect(await titles("plumber", indexer).isEmpty)
    }

    @Test func notesNotYetDownloadedAreFoundByTitle() async throws {
        let file = NoteFile(
            url: URL(filePath: "/missing/Recipes.md"),
            relativePath: "Recipes.md",
            modifiedDate: today,
            isDownloaded: false
        )
        let indexer = try makeIndexer(source: FakeCalendarDataSource())
        await indexer.activate()
        await indexer.updateNotes([file])
        #expect(await titles("recipe", indexer) == ["Recipes"])
    }
}
