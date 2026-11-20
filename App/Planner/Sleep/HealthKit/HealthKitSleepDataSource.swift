#if os(iOS)
import Foundation
import HealthKit
import os
import Synchronization

private let sleepLog = Logger(subsystem: "com.tsubuzaki.Folio", category: "Sleep")

public final class HealthKitSleepDataSource: SleepDataSource {
    static let sleepType = HKCategoryType(.sleepAnalysis)
    let store = HKHealthStore()
    private let observerQuery = Mutex<HKObserverQuery?>(nil)

    public init() {}

    public func authorizationRequestStatus() async -> SleepAuthorizationRequestStatus {
        guard HKHealthStore.isHealthDataAvailable() else { return .unavailable }
        let status = try? await store.statusForAuthorizationRequest(toShare: [], read: [Self.sleepType])
        return status == .shouldRequest ? .shouldRequest : .requested
    }

    public func requestAuthorization() async throws {
        try await store.requestAuthorization(toShare: [], read: [Self.sleepType])
    }

    public func samples(in interval: DateInterval) async throws -> [SleepSample] {
        let predicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.categorySample(type: Self.sleepType, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.startDate)]
        )
        return try await descriptor.result(for: store).compactMap(SleepSample.init(healthKitSample:))
    }

    public func startObservingChanges(_ onChange: @escaping @Sendable () async -> Void) {
        let query = HKObserverQuery(sampleType: Self.sleepType, predicate: nil) { _, completion, error in
            let completion = SleepObserverCompletion(handler: completion)
            if let error {
                sleepLog.error("Sleep observer failed: \(error.localizedDescription, privacy: .public)")
                completion.finish()
                return
            }
            Task {
                await onChange()
                completion.finish()
            }
        }
        let isStarted = observerQuery.withLock { running in
            guard running == nil else { return false }
            running = query
            return true
        }
        guard isStarted else { return }
        store.execute(query)
        store.enableBackgroundDelivery(for: Self.sleepType, frequency: .immediate) { _, error in
            guard let error else { return }
            // swiftlint:disable:next line_length
            sleepLog.error("Sleep background delivery could not be turned on: \(error.localizedDescription, privacy: .public)")
        }
    }

    public func stopObservingChanges() {
        let query = observerQuery.withLock { running in
            defer { running = nil }
            return running
        }
        guard let query else { return }
        store.stop(query)
        store.disableBackgroundDelivery(for: Self.sleepType) { _, error in
            guard let error else { return }
            // swiftlint:disable:next line_length
            sleepLog.error("Sleep background delivery could not be turned off: \(error.localizedDescription, privacy: .public)")
        }
    }
}

private struct SleepObserverCompletion: @unchecked Sendable {
    let handler: HKObserverQueryCompletionHandler

    func finish() {
        handler()
    }
}
#endif
