#if os(iOS)
import Foundation
import HealthKit

public final class HealthKitMedicationDataSource: MedicationDataSource {
    static let doseType = HKObjectType.medicationDoseEventType()
    let store = HKHealthStore()

    public init() {}

    public func requestAuthorization() async throws {
        try await store.requestPerObjectReadAuthorization(
            for: HKObjectType.userAnnotatedMedicationType(),
            predicate: nil
        )
    }

    public func scheduledMedications() async throws -> [Medication] {
        try await annotatedMedications().map(Medication.init(healthKitMedication:))
    }

    public func doseRecords(in interval: DateInterval) async throws -> [MedicationDoseRecord] {
        let medications = Dictionary(
            try await annotatedMedications().map {
                ($0.medication.identifier, Medication(healthKitMedication: $0))
            },
            uniquingKeysWith: { first, _ in first }
        )
        let predicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.sample(type: Self.doseType, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.startDate)]
        )
        return try await descriptor.result(for: store).compactMap { sample in
            guard let event = sample as? HKMedicationDoseEvent,
                  let medication = medications[event.medicationConceptIdentifier] else { return nil }
            return MedicationDoseRecord(healthKitEvent: event, medication: medication)
        }
    }

    public func startObservingChanges(_ onChange: @escaping @Sendable () async -> Void) {
        let query = HKObserverQuery(sampleType: Self.doseType, predicate: nil) { _, completion, error in
            let completion = MedicationObserverCompletion(handler: completion)
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
        store.enableBackgroundDelivery(for: Self.doseType, frequency: .immediate) { _, _ in }
    }

    private func annotatedMedications() async throws -> [HKUserAnnotatedMedication] {
        try await HKUserAnnotatedMedicationQueryDescriptor().result(for: store)
            .filter { $0.hasSchedule && !$0.isArchived }
    }
}

private struct MedicationObserverCompletion: @unchecked Sendable {
    let handler: HKObserverQueryCompletionHandler

    func finish() {
        handler()
    }
}
#endif
