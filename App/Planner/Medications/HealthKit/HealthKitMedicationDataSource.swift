#if os(iOS)
import Foundation
import HealthKit
import os
import Synchronization

private let medicationLog = Logger(subsystem: "com.tsubuzaki.Folio", category: "Medications")

public final class HealthKitMedicationDataSource: MedicationDataSource {
    static let doseType = HKObjectType.medicationDoseEventType()
    let store = HKHealthStore()
    private let observerQuery = Mutex<HKObserverQuery?>(nil)

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
            if let error {
                medicationLog.error("Medication observer failed: \(error.localizedDescription, privacy: .public)")
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
        store.enableBackgroundDelivery(for: Self.doseType, frequency: .immediate) { _, error in
            guard let error else { return }
            // swiftlint:disable:next line_length
            medicationLog.error("Medication background delivery could not be turned on: \(error.localizedDescription, privacy: .public)")
        }
    }

    public func stopObservingChanges() {
        let query = observerQuery.withLock { running in
            defer { running = nil }
            return running
        }
        guard let query else { return }
        store.stop(query)
        store.disableBackgroundDelivery(for: Self.doseType) { _, error in
            guard let error else { return }
            // swiftlint:disable:next line_length
            medicationLog.error("Medication background delivery could not be turned off: \(error.localizedDescription, privacy: .public)")
        }
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
