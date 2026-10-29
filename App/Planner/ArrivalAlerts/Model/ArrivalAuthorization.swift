import Foundation

public enum ArrivalAuthorization: Sendable, Equatable {
    case notDetermined
    case whenInUse
    case always
    case denied

    public var allowsMonitoring: Bool {
        self == .whenInUse || self == .always
    }
}
