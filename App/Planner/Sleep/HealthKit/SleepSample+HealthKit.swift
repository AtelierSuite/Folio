#if os(iOS)
import Foundation
import HealthKit

extension SleepSample {
    init?(healthKitSample sample: HKCategorySample) {
        guard let value = HKCategoryValueSleepAnalysis(rawValue: sample.value),
              let stage = SleepStage(healthKitValue: value) else { return nil }
        self.init(
            stage: stage,
            interval: DateInterval(start: sample.startDate, end: max(sample.startDate, sample.endDate)),
            source: SleepSource(healthKitSample: sample)
        )
    }
}

extension SleepStage {
    init?(healthKitValue value: HKCategoryValueSleepAnalysis) {
        switch value {
        case .inBed: self = .inBed
        case .asleepUnspecified: self = .asleep
        case .asleepCore: self = .core
        case .asleepDeep: self = .deep
        case .asleepREM: self = .rem
        case .awake: self = .awake
        @unknown default: return nil
        }
    }

    var healthKitValue: HKCategoryValueSleepAnalysis {
        switch self {
        case .inBed: .inBed
        case .asleep: .asleepUnspecified
        case .core: .asleepCore
        case .deep: .asleepDeep
        case .rem: .asleepREM
        case .awake: .awake
        }
    }
}

extension SleepSource {
    init(healthKitSample sample: HKSample) {
        let revision = sample.sourceRevision
        self.init(
            id: revision.source.bundleIdentifier,
            name: revision.source.name,
            kind: Kind(bundleIdentifier: revision.source.bundleIdentifier, productType: revision.productType)
        )
    }
}
#endif
