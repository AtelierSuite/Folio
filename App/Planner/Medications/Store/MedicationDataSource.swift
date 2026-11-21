import Foundation

/// Reads medications from the system. Everything read is only ever held in memory.
public protocol MedicationDataSource: Sendable {
    /// Always shows the system sheet, where each medication is shared on its own.
    func requestAuthorization() async throws
    func scheduledMedications() async throws -> [Medication]
    /// The scheduled medications and the doses logged in any of `intervals`, read together.
    func records(loggedIn intervals: [DateInterval]) async throws -> MedicationRecords
    func startObservingChanges(_ onChange: @escaping @Sendable () async -> Void)
    /// Stops the observer and background delivery started by `startObservingChanges`.
    func stopObservingChanges()
}
