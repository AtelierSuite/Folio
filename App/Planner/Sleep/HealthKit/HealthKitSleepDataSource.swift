#if os(iOS)
import Foundation
import HealthKit

public final class HealthKitSleepDataSource: SleepDataSource {
    static let sleepType = HKCategoryType(.sleepAnalysis)
    let store = HKHealthStore()

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
            guard error == nil else {
                completion.finish()
                return
            }
            Task {
                await onChange()
                completion.finish()
            }
        }
        store.execute(query)
        store.enableBackgroundDelivery(for: Self.sleepType, frequency: .immediate) { _, _ in }
    }
}

private struct SleepObserverCompletion: @unchecked Sendable {
    let handler: HKObserverQueryCompletionHandler

    func finish() {
        handler()
    }
}
#endif
