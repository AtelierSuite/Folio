#if os(iOS)
import Foundation
import HealthKit

extension Medication {
    init(healthKitMedication medication: HKUserAnnotatedMedication) {
        let displayText = medication.medication.displayText
        let name = medication.nickname ?? displayText
        self.init(
            id: displayText,
            name: name,
            fullName: name == displayText ? nil : displayText,
            doseUnit: MedicationDoseUnit(generalForm: medication.medication.generalForm)
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
            status: MedicationDoseStatus(logStatus: event.logStatus),
            amount: event.scheduledDoseQuantity.map { quantity in
                let isCounted = event.unit == HKUnit.count()
                return MedicationDoseAmount(
                    quantity: quantity,
                    unit: isCounted ? medication.doseUnit : .measured(event.unit.unitString)
                )
            }
        )
    }
}

extension MedicationDoseUnit {
    init(generalForm: HKMedicationGeneralForm) {
        switch generalForm {
        case .tablet: self = .tablet
        case .capsule: self = .capsule
        case .drops: self = .drop
        case .injection: self = .injection
        case .inhaler: self = .puff
        case .patch: self = .patch
        case .spray: self = .spray
        case .suppository: self = .suppository
        case .cream, .foam, .gel, .lotion, .ointment, .topical: self = .application
        default: self = .dose
        }
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
