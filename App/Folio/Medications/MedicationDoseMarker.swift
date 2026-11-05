import Foundation
import Planner

/// The doses due at one moment, drawn as a single marker so they never stack on top of each other.
struct MedicationDoseMarker: Identifiable {
    let date: Date
    let names: [String]
    let status: MedicationDoseStatus

    var id: Date { date }

    static func markers(for doses: [MedicationDose]) -> [MedicationDoseMarker] {
        Dictionary(grouping: doses, by: \.date)
            .map { date, doses in
                let statuses = Set(doses.map(\.status))
                return MedicationDoseMarker(
                    date: date,
                    names: doses.map(\.medication.name).sorted(),
                    status: statuses.count == 1 ? statuses.first ?? .notLogged : .notLogged
                )
            }
            .sorted { $0.date < $1.date }
    }

    var title: String {
        ListFormatter.localizedString(byJoining: names)
    }

    var accessibilityLabel: String {
        [title, date.formatted(date: .omitted, time: .shortened), status.title].joined(separator: ", ")
    }
}

extension MedicationDoseStatus {
    var title: String {
        switch self {
        case .taken: String(localized: "Status.Taken", table: "Medications")
        case .skipped: String(localized: "Status.Skipped", table: "Medications")
        case .notLogged: String(localized: "Status.NotLogged", table: "Medications")
        case .estimated: String(localized: "Status.Estimated", table: "Medications")
        }
    }
}
