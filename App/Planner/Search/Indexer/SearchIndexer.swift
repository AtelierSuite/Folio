import Foundation
import Observation

/// Keeps a search index of events and reminders in the configured range and of every note.
/// It starts indexing on `activate()`, so nothing is fetched until search is first used.
@MainActor
@Observable
public final class SearchIndexer {
    public private(set) var range: SearchRange
    public private(set) var isActive = false
    public private(set) var isIndexing = false
    /// Bumps after every change to the index, so open searches know to run again.
    public private(set) var revision = 0

    @ObservationIgnored let catalog = SearchCatalog()
    @ObservationIgnored let source: any CalendarDataSource
    @ObservationIgnored private let storage: SearchRangeStorage
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private let now: @Sendable () -> Date
    @ObservationIgnored private var lastWork: Task<Void, Never>?
    @ObservationIgnored private var pendingWorkCount = 0

    public init(
        source: any CalendarDataSource = EventKitDataSource.shared,
        storage: SearchRangeStorage = SearchRangeStorage(),
        calendar: Calendar = .current,
        now: @escaping @Sendable () -> Date = { .now }
    ) {
        self.source = source
        self.storage = storage
        self.calendar = calendar
        self.now = now
        range = storage.range
    }

    public var indexedInterval: DateInterval {
        range.interval(around: now(), calendar: calendar)
    }

    public func activate() async {
        guard !isActive else { return }
        isActive = true
        await reindexCalendar()
    }

    public func setRange(_ newRange: SearchRange) async {
        guard newRange != range else { return }
        range = newRange
        storage.range = newRange
        await reindexCalendar()
    }

    public func search(_ query: SearchQuery) async -> [SearchDocument] {
        await catalog.search(query)
    }

    /// Runs index updates one after another, so a slow fetch can't overwrite a newer one.
    func perform(_ work: @escaping @Sendable () async -> Void) async {
        let previous = lastWork
        let task = Task {
            await previous?.value
            await work()
        }
        lastWork = task
        pendingWorkCount += 1
        isIndexing = true
        await task.value
        pendingWorkCount -= 1
        isIndexing = pendingWorkCount > 0
        revision += 1
    }
}
