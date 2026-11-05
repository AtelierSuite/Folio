import Foundation
import Testing
@testable import Planner

struct NotificationMedicationDetailTests {
    private static let date = Date(timeIntervalSince1970: 1_800_000_000)

    private var reminder: MedicationReminder {
        let medication = Medication(
            id: "allergy", name: "Allergy Pill", fullName: "Cetirizine 10 mg Tablet", doseUnit: .tablet
        )
        let dose = MedicationDose(
            medication: medication,
            date: Self.date,
            status: .estimated,
            amount: MedicationDoseAmount(quantity: 1, unit: .tablet)
        )
        return MedicationReminder(date: Self.date, doses: [dose])
    }

    @Test func expandedAlertReadsTheDosesBack() throws {
        let reminder = reminder
        let detail = NotificationDetail(
            title: reminder.title,
            body: reminder.body,
            userInfo: NotificationUserInfo.make(for: reminder)
        )
        let medication = try #require(detail.medication)
        #expect(medication.doses == reminder.doses)
        #expect(medication.doses.first?.summary?.hasSuffix(" · Cetirizine 10 mg Tablet") == true)
        #expect(detail.status(at: Self.date.addingTimeInterval(-600)) != nil)
        #expect(detail.isOverdue(at: Self.date.addingTimeInterval(600)))
        #expect(detail.row(.time) != nil)
        #expect(detail.origin != nil)
    }
}
