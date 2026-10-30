import Foundation
@testable import Planner

final class FakeSleepDataSource: SleepDataSource, @unchecked Sendable {
    private let lock = NSLock()
    private var storedSamples: [SleepSample]
    private var storedStatus: SleepAuthorizationRequestStatus
    private var storedFetchCount = 0
    private var storedOnChange: (@Sendable () async -> Void)?
    private var storedRequestCount = 0
    private var storedFailsReads = false

    init(samples: [SleepSample] = [], status: SleepAuthorizationRequestStatus = .shouldRequest) {
        storedSamples = samples
        storedStatus = status
    }

    var samples: [SleepSample] {
        get { lock.withLock { storedSamples } }
        set { lock.withLock { storedSamples = newValue } }
    }

    var failsReads: Bool {
        get { lock.withLock { storedFailsReads } }
        set { lock.withLock { storedFailsReads = newValue } }
    }

    var fetchCount: Int { lock.withLock { storedFetchCount } }
    var requestCount: Int { lock.withLock { storedRequestCount } }
    var isObserving: Bool { lock.withLock { storedOnChange != nil } }

    func authorizationRequestStatus() async -> SleepAuthorizationRequestStatus {
        lock.withLock { storedStatus }
    }

    func requestAuthorization() async throws {
        lock.withLock {
            storedRequestCount += 1
            storedStatus = .requested
        }
    }

    func samples(in interval: DateInterval) async throws -> [SleepSample] {
        try lock.withLock {
            storedFetchCount += 1
            if storedFailsReads {
                throw CocoaError(.fileReadNoPermission)
            }
            return storedSamples.filter { $0.interval.intersects(interval) }
        }
    }

    func startObservingChanges(_ onChange: @escaping @Sendable () async -> Void) {
        lock.withLock { storedOnChange = onChange }
    }

    func simulateChange() async {
        let onChange = lock.withLock { storedOnChange }
        await onChange?()
    }
}
