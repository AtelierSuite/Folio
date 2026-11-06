import Foundation

public struct MedicationReminder: Identifiable, Sendable, Hashable {
    static let identifierPrefix = "folio.medication."
    static let categoryIdentifier = "folio.medication"
    static let limit = 12
    /// Kept short so reminders run out, rather than carry on at old times, if Folio can't reach Health.
    static let lookAhead: TimeInterval = 3 * 86_400

    public let id: String
    public let date: Date
    public let title: String
    public let body: String
    public let doses: [NotificationMedicationDetails.Dose]

    init(date: Date, doses: [MedicationDose]) {
        let sorted = doses.sorted { $0.medication.name < $1.medication.name }
        let title = ListFormatter.localizedString(byJoining: sorted.map(\.medication.name))
        let body = Self.body(for: sorted)
        let details = sorted.map(NotificationMedicationDetails.Dose.init(dose:))
        let fingerprint = ([title, body] + details.compactMap(\.summary)).joined(separator: "\n")
        let seconds = Int(date.timeIntervalSince1970.rounded(.down))
        id = "\(Self.identifierPrefix)\(seconds).\(NotificationIdentifier.stableDigest(of: fingerprint))"
        self.date = date
        self.title = title
        self.body = body
        self.doses = details
    }

    static var estimateNote: String {
        String(localized: "Reminder.Body", table: "Medications", bundle: #bundle)
    }

    static func reminders(for doses: [MedicationDose]) -> [MedicationReminder] {
        Dictionary(grouping: doses, by: \.date)
            .map { date, doses in MedicationReminder(date: date, doses: doses) }
            .sorted { $0.date < $1.date }
            .prefix(limit)
            .map(\.self)
    }

    private static func body(for doses: [MedicationDose]) -> String {
        let amounts = doses.compactMap { dose in
            dose.amount.map { amount in
                guard doses.count > 1 else { return amount.text }
                return String(
                    format: String(localized: "Dose.NamedAmount", table: "Medications", bundle: #bundle),
                    dose.medication.name,
                    amount.text
                )
            }
        }
        return (amounts + [estimateNote]).joined(separator: "\n")
    }
}
