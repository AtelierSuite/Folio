import Foundation

public struct MedicationDose: Identifiable, Sendable, Hashable {
    public let medication: Medication
    public let date: Date
    public let status: MedicationDoseStatus

    public init(medication: Medication, date: Date, status: MedicationDoseStatus) {
        self.medication = medication
        self.date = date
        self.status = status
    }

    public var id: String {
        "\(medication.id)@\(date.timeIntervalSince1970)"
    }
}

extension MedicationDose {
    static func latest(from records: [MedicationDoseRecord]) -> [MedicationDose] {
        let slots = Dictionary(grouping: records) { SlotKey(medication: $0.medication, date: $0.scheduledDate) }
        return slots.compactMap { slot, records in
            records.max { $0.loggedDate < $1.loggedDate }.map {
                MedicationDose(medication: slot.medication, date: slot.date, status: $0.status)
            }
        }
        .sorted { ($0.date, $0.medication.name) < ($1.date, $1.medication.name) }
    }

    private struct SlotKey: Hashable {
        let medication: Medication
        let date: Date
    }
}
