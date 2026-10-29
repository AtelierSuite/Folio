import Planner
import SwiftUI

extension PermissionStatus {
    var label: String {
        switch self {
        case .notDetermined: String(localized: "Status.NotDetermined", table: "Permissions")
        case .limited: String(localized: "Status.Limited", table: "Permissions")
        case .granted: String(localized: "Status.Granted", table: "Permissions")
        case .denied: String(localized: "Status.Denied", table: "Permissions")
        case .restricted: String(localized: "Status.Restricted", table: "Permissions")
        case .unknown: String(localized: "Status.Unknown", table: "Permissions")
        case .unavailable: String(localized: "Status.Unavailable", table: "Permissions")
        }
    }
}
