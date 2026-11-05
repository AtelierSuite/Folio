import Foundation

public enum MedicationDoseStatus: Sendable, Hashable {
    case taken
    case skipped
    case notLogged
    case estimated
}
