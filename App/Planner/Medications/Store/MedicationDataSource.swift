import Foundation

/// Reads medications from the system. Everything read is only ever held in memory.
public protocol MedicationDataSource: Sendable {
    /// Always shows the system sheet, where each medication is shared on its own.
    func requestAuthorization() async throws
    func scheduledMedications() async throws -> [Medication]
    func doseRecords(in interval: DateInterval) async throws -> [MedicationDoseRecord]
    func startObservingChanges(_ onChange: @escaping @Sendable () async -> Void)
}
