import Foundation
import Synchronization
import Testing
@testable import Planner

struct HolidayRepositoryTests {
    final class RequestLog: Sendable {
        let urls = Mutex<[URL]>([])
        var count: Int { urls.withLock(\.count) }
    }

    static let now = Date(timeIntervalSince1970: 1_793_000_000)
    static let staleNow = now.addingTimeInterval(HolidayRepository.maximumCacheAge + 1)
    static let govUKResponse = Data("""
    {"england-and-wales":{"events":[{"title":"Christmas Day","date":"2026-12-25"}]}}
    """.utf8)

    static func repository(
        in directory: TemporaryDirectory, log: RequestLog, failing: Bool = false
    ) -> HolidayRepository {
        HolidayRepository(cache: HolidayCache(directory: directory.url)) { url in
            log.urls.withLock { $0.append(url) }
            if failing { throw URLError(.notConnectedToInternet) }
            return govUKResponse
        }
    }

    @Test func fetchesThenServesFreshCache() async throws {
        let directory = try TemporaryDirectory()
        let log = RequestLog()
        let repository = Self.repository(in: directory, log: log)
        let first = await repository.holidays(for: .govUK, now: Self.now)
        let second = await repository.holidays(for: .govUK, now: Self.now.addingTimeInterval(60 * 60))
        #expect(first.map(\.name) == ["Christmas Day"])
        #expect(second == first)
        #expect(log.count == 1)
    }

    @Test func refetchesStaleCache() async throws {
        let directory = try TemporaryDirectory()
        let log = RequestLog()
        let repository = Self.repository(in: directory, log: log)
        _ = await repository.holidays(for: .govUK, now: Self.now)
        _ = await repository.holidays(for: .govUK, now: Self.staleNow)
        #expect(log.count == 2)
    }

    @Test func fallsBackToStaleCacheWhenOffline() async throws {
        let directory = try TemporaryDirectory()
        let log = RequestLog()
        _ = await Self.repository(in: directory, log: log).holidays(for: .govUK, now: Self.now)
        let offline = Self.repository(in: directory, log: log, failing: true)
        let holidays = await offline.holidays(for: .govUK, now: Self.staleNow)
        #expect(holidays.map(\.name) == ["Christmas Day"])
    }

    @Test func returnsNothingWhenOfflineWithoutCache() async throws {
        let directory = try TemporaryDirectory()
        let holidays = await Self.repository(in: directory, log: RequestLog(), failing: true)
            .holidays(for: .govUK, now: Self.now)
        #expect(holidays.isEmpty)
    }

    @Test func refreshBypassesFreshCache() async throws {
        let directory = try TemporaryDirectory()
        let log = RequestLog()
        let repository = Self.repository(in: directory, log: log)
        _ = await repository.holidays(for: .govUK, now: Self.now)
        let later = Self.now.addingTimeInterval(60)
        try await repository.refresh(.govUK, now: later)
        #expect(log.count == 2)
        #expect(repository.lastUpdated(.govUK) == later)
    }

    @Test func failedRefreshThrowsAndKeepsCache() async throws {
        let directory = try TemporaryDirectory()
        let log = RequestLog()
        _ = await Self.repository(in: directory, log: log).holidays(for: .govUK, now: Self.now)
        let offline = Self.repository(in: directory, log: log, failing: true)
        await #expect(throws: (any Error).self) { try await offline.refresh(.govUK, now: Self.staleNow) }
        #expect(offline.lastUpdated(.govUK) == Self.now)
    }
}
