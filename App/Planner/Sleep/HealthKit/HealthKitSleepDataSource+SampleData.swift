#if os(iOS) && DEBUG
import Foundation
import HealthKit

extension HealthKitSleepDataSource {
    /// Replaces the sleep this app wrote before with a week of sample nights.
    public func writeSampleData(now: Date = Date(), calendar: Calendar = .current) async throws {
        try await store.requestAuthorization(toShare: [Self.sleepType], read: [Self.sleepType])
        _ = try await store.deleteObjects(of: Self.sleepType, predicate: HKQuery.predicateForObjects(from: .default()))
        let samples = SleepSampleData.nights(count: 7, endingBefore: now, calendar: calendar).map { sample in
            HKCategorySample(
                type: Self.sleepType,
                value: sample.stage.healthKitValue.rawValue,
                start: sample.interval.start,
                end: sample.interval.end
            )
        }
        try await store.save(samples)
    }
}
#endif
