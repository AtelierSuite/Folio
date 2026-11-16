import Foundation
import Planner

/// The doses due at one moment, drawn as a single marker so they never stack on top of each other.
struct MedicationDoseMarker: Identifiable {
    let date: Date
    let names: [String]
    let status: MedicationDoseStatus

    var id: String { "medication.\(date.timeIntervalSinceReferenceDate)" }

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

    /// Laid out like a timed reminder so it shares columns with the cards at the same time.
    func timelineEntry(in timeZone: TimeZone) -> TimelineEntry {
        TimelineEntry(
            id: id,
            title: title,
            start: date,
            end: date,
            timeZone: timeZone,
            color: TimelineColor(red: 0.19, green: 0.69, blue: 0.78),
            isReadOnly: true,
            kind: .medication,
            isCompleted: status == .taken || status == .skipped
        )
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
