import Foundation

public struct Medication: Identifiable, Sendable, Hashable {
    public let id: String
    public let name: String
    /// Set when `name` is a nickname, so the alert can still say what the medication is.
    public let fullName: String?
    public let doseUnit: MedicationDoseUnit

    public init(id: String, name: String, fullName: String? = nil, doseUnit: MedicationDoseUnit = .dose) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.doseUnit = doseUnit
    }
}
