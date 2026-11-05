#if os(iOS)
import Foundation
import HealthKit

extension Medication {
    init(healthKitMedication medication: HKUserAnnotatedMedication) {
        self.init(
            id: medication.medication.displayText,
            name: medication.nickname ?? medication.medication.displayText
        )
    }
}

extension MedicationDoseRecord {
    init?(healthKitEvent event: HKMedicationDoseEvent, medication: Medication) {
        guard event.scheduleType == .schedule, let scheduledDate = event.scheduledDate else { return nil }
        self.init(
            medication: medication,
            scheduledDate: scheduledDate,
            loggedDate: event.startDate,
            status: MedicationDoseStatus(logStatus: event.logStatus)
        )
    }
}

extension MedicationDoseStatus {
    init(logStatus: HKMedicationDoseEvent.LogStatus) {
        switch logStatus {
        case .taken: self = .taken
        case .skipped: self = .skipped
        default: self = .notLogged
        }
    }
}
#endif
