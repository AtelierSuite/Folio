import Foundation

public struct MedicationRecords: Sendable, Equatable {
    public let medications: [Medication]
    public let doseRecords: [MedicationDoseRecord]

    public init(medications: [Medication], doseRecords: [MedicationDoseRecord]) {
        self.medications = medications
        self.doseRecords = doseRecords
    }

    func doseRecords(loggedIn interval: DateInterval) -> [MedicationDoseRecord] {
        doseRecords.filter { interval.contains($0.loggedDate) }
    }
}
