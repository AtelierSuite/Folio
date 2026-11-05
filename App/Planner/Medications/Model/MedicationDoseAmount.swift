import Foundation

public struct MedicationDoseAmount: Sendable, Hashable {
    public let quantity: Double
    public let unit: MedicationDoseUnit

    public init(quantity: Double, unit: MedicationDoseUnit) {
        self.quantity = quantity
        self.unit = unit
    }

    public var text: String {
        let quantityText = quantity.formatted(.number.precision(.fractionLength(0...2)))
        guard let unitKey = unit.localizationKey else {
            return "\(quantityText) \(unit.symbol)"
        }
        let key = "Dose.Unit.\(unitKey).\(quantity > 1 ? "Many" : "One")"
        return String(
            format: String(localized: "Dose.Amount", table: "Medications", bundle: #bundle),
            quantityText,
            String(localized: String.LocalizationValue(key), table: "Medications", bundle: #bundle)
        )
    }
}
