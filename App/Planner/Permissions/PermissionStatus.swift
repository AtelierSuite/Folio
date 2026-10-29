import Foundation

public enum PermissionStatus: String, Sendable, Hashable {
    case notDetermined
    case limited
    case granted
    case denied
    case restricted
    case unknown
    case unavailable

    public var allowsAccess: Bool {
        self == .granted || self == .unknown
    }

    public var canRequest: Bool {
        self == .notDetermined || self == .limited
    }

    public var canBeFixedInSettings: Bool {
        self == .denied
    }

    public var mayHideMissingAccess: Bool {
        self == .unknown
    }
}
