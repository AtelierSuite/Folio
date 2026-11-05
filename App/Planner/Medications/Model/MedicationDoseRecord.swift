import Foundation

/// One log entry from Health. A dose slot can have several, such as a snooze followed by a taken.
public struct MedicationDoseRecord: Sendable, Hashable {
    public let medication: Medication
    public let scheduledDate: Date
    public let loggedDate: Date
    public let status: MedicationDoseStatus
    public let amount: MedicationDoseAmount?

    public init(
        medication: Medication,
        scheduledDate: Date,
        loggedDate: Date,
        status: MedicationDoseStatus,
        amount: MedicationDoseAmount? = nil
    ) {
        self.medication = medication
        self.scheduledDate = scheduledDate
        self.loggedDate = loggedDate
        self.status = status
        self.amount = amount
    }
}
