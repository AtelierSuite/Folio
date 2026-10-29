import Foundation

extension PermissionStatus {
    public init(_ status: CalendarAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .restricted: self = .restricted
        case .denied: self = .denied
        case .writeOnly: self = .limited
        case .fullAccess: self = .granted
        }
    }
}
