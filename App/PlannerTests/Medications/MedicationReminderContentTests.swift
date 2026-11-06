import Foundation
import Testing
@testable import Planner

struct MedicationReminderContentTests {
    private static let date = Date(timeIntervalSince1970: 1_800_000_000)
    private static let vitamin = Medication(id: "vitamin", name: "Vitamin D", doseUnit: .capsule)
    private static let allergy = Medication(
        id: "allergy", name: "Allergy Pill", fullName: "Cetirizine 10 mg Tablet", doseUnit: .tablet
    )

    private func dose(_ medication: Medication, quantity: Double?) -> MedicationDose {
        MedicationDose(
            medication: medication,
            date: Self.date,
            status: .estimated,
            amount: quantity.map { MedicationDoseAmount(quantity: $0, unit: medication.doseUnit) }
        )
    }

    private func localized(_ key: String) -> String {
        String(
            localized: String.LocalizationValue(key),
            table: "Medications",
            bundle: Bundle(for: MedicationStore.self)
        )
    }

    private func amount(_ quantity: String, _ unitKey: String) -> String {
        String(format: localized("Dose.Amount"), quantity, localized(unitKey))
    }

    private func named(_ name: String, _ amount: String) -> String {
        String(format: localized("Dose.NamedAmount"), name, amount)
    }

    @Test func amountNamesTheUnitInTheRightNumber() {
        let oneAndAHalf = 1.5.formatted()
        #expect(MedicationDoseAmount(quantity: 1, unit: .tablet).text == amount("1", "Dose.Unit.Tablet.One"))
        #expect(MedicationDoseAmount(quantity: 2, unit: .capsule).text == amount("2", "Dose.Unit.Capsule.Many"))
        #expect(
            MedicationDoseAmount(quantity: 1.5, unit: .tablet).text == amount(oneAndAHalf, "Dose.Unit.Tablet.Many")
        )
        #expect(MedicationDoseAmount(quantity: 5, unit: .measured("mL")).text == "5 mL")
    }

    @Test func singleDoseBodyLeadsWithItsAmount() {
        let reminder = MedicationReminder(date: Self.date, doses: [dose(Self.vitamin, quantity: 2)])
        #expect(reminder.body == "\(amount("2", "Dose.Unit.Capsule.Many"))\n\(MedicationReminder.estimateNote)")
    }

    @Test func sharedTimeBodyNamesEachMedication() {
        let reminder = MedicationReminder(
            date: Self.date,
            doses: [dose(Self.vitamin, quantity: 2), dose(Self.allergy, quantity: 1)]
        )
        let lines = [
            named("Allergy Pill", amount("1", "Dose.Unit.Tablet.One")),
            named("Vitamin D", amount("2", "Dose.Unit.Capsule.Many")),
            MedicationReminder.estimateNote
        ]
        #expect(reminder.body == lines.joined(separator: "\n"))
    }

    @Test func bodyWithoutAnAmountKeepsTheEstimateNote() {
        let reminder = MedicationReminder(date: Self.date, doses: [dose(Self.vitamin, quantity: nil)])
        #expect(reminder.body == MedicationReminder.estimateNote)
    }

    @Test func changingADoseReplacesThePendingReminder() {
        let before = MedicationReminder(date: Self.date, doses: [dose(Self.vitamin, quantity: 1)])
        let after = MedicationReminder(date: Self.date, doses: [dose(Self.vitamin, quantity: 2)])
        #expect(before.id != after.id)
    }
}
