import Foundation

/// What only medication alerts show in the expanded alert. Its presence selects the medication layout.
public struct NotificationMedicationDetails: Sendable, Hashable, Codable {
    public struct Dose: Sendable, Hashable, Codable, Identifiable {
        public let name: String
        public let summary: String?

        public var id: String { name }

        public init(name: String, summary: String?) {
            self.name = name
            self.summary = summary
        }

        init(dose: MedicationDose) {
            let parts = [dose.amount?.text, dose.medication.fullName].compactMap { $0 }
            self.init(name: dose.medication.name, summary: parts.isEmpty ? nil : parts.joined(separator: " · "))
        }
    }

    public let dueDate: Date
    public let doses: [Dose]
    public let note: String

    public init(dueDate: Date, doses: [Dose], note: String) {
        self.dueDate = dueDate
        self.doses = doses
        self.note = note
    }
}
