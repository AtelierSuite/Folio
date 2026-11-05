#if DEBUG
import Foundation

/// Made-up doses for testing, since HealthKit won't let an app write medications.
/// Turned on with `-FolioSampleMedications`.
public struct SampleMedicationDataSource: MedicationDataSource {
    public static let launchArgument = "-FolioSampleMedications"
    private static let vitamin = Medication(id: "sample.vitamin", name: "Vitamin D")
    private static let allergy = Medication(id: "sample.allergy", name: "Cetirizine")

    private let calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    public func requestAuthorization() async throws {}

    public func scheduledMedications() async throws -> [Medication] {
        [Self.vitamin, Self.allergy]
    }

    public func doseRecords(in interval: DateInterval) async throws -> [MedicationDoseRecord] {
        let today = calendar.startOfDay(for: Date())
        let doses = (1...MedicationDoseForecast.historyDays).flatMap { offset -> [MedicationDoseRecord] in
            let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            return [
                record(Self.vitamin, day: day, hour: 8, status: offset == 2 ? .skipped : .taken),
                record(Self.allergy, day: day, hour: 21, status: offset == 1 ? .notLogged : .taken)
            ]
        }
        return doses.filter { interval.contains($0.loggedDate) }
    }

    public func startObservingChanges(_ onChange: @escaping @Sendable () async -> Void) {}

    private func record(
        _ medication: Medication,
        day: Date,
        hour: Int,
        status: MedicationDoseStatus
    ) -> MedicationDoseRecord {
        let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day) ?? day
        return MedicationDoseRecord(medication: medication, scheduledDate: date, loggedDate: date, status: status)
    }
}
#endif
