import Foundation

public enum MedicationDoseUnit: Sendable, Hashable {
    case tablet
    case capsule
    case drop
    case injection
    case puff
    case patch
    case spray
    case suppository
    case application
    case dose
    case measured(String)

    var symbol: String {
        if case .measured(let symbol) = self { symbol } else { "" }
    }

    var localizationKey: String? {
        switch self {
        case .tablet: "Tablet"
        case .capsule: "Capsule"
        case .drop: "Drop"
        case .injection: "Injection"
        case .puff: "Puff"
        case .patch: "Patch"
        case .spray: "Spray"
        case .suppository: "Suppository"
        case .application: "Application"
        case .dose: "Dose"
        case .measured: nil
        }
    }
}
