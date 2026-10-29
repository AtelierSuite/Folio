import Foundation

public enum NotificationAuthorization: Sendable, Hashable {
    case notDetermined
    case denied
    case authorized

    public var allowsScheduling: Bool {
        self == .authorized
    }
}
