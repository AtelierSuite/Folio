import Foundation

public enum CalendarAuthorizationStatus: String, Sendable, Hashable {
    case notDetermined
    case restricted
    case denied
    case writeOnly
    case fullAccess

    public var allowsReading: Bool {
        self == .fullAccess
    }
}
