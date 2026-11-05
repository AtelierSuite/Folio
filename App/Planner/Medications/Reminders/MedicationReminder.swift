import Foundation

public struct MedicationReminder: Identifiable, Sendable, Hashable {
    static let identifierPrefix = "folio.medication."
    static let limit = 12
    /// Kept short so reminders run out, rather than carry on at old times, if Folio can't reach Health.
    static let lookAhead: TimeInterval = 3 * 86_400

    public let id: String
    public let date: Date
    public let title: String
    public let body: String

    init(date: Date, medicationNames: [String]) {
        let title = ListFormatter.localizedString(byJoining: medicationNames)
        let seconds = Int(date.timeIntervalSince1970.rounded(.down))
        id = "\(Self.identifierPrefix)\(seconds).\(NotificationIdentifier.stableDigest(of: title))"
        self.date = date
        self.title = title
        body = String(localized: "Reminder.Body", table: "Medications", bundle: #bundle)
    }

    static func reminders(for doses: [MedicationDose]) -> [MedicationReminder] {
        Dictionary(grouping: doses, by: \.date)
            .map { date, doses in
                MedicationReminder(date: date, medicationNames: doses.map(\.medication.name).sorted())
            }
            .sorted { $0.date < $1.date }
            .prefix(limit)
            .map(\.self)
    }
}
