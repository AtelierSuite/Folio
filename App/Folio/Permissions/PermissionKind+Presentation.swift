import Planner
import SwiftUI

extension PermissionKind {
    var name: String {
        localized("Name")
    }

    var systemImage: String {
        switch self {
        case .calendar: "calendar"
        case .reminders: "checklist"
        case .notifications: "bell.badge"
        case .location: "location"
        case .health: "heart"
        case .alarms: "alarm"
        }
    }

    var requestTitle: String { localized("Request.Title") }
    var requestDescription: String { localized("Request.Description") }
    var requestAction: String { localized("Request.Action") }
    var deniedTitle: String { localized("Denied.Title") }
    var deniedDescription: String { localized("Denied.Description") }

    private func localized(_ suffix: String) -> String {
        let key = "\(keyPrefix).\(suffix)"
        return String(localized: String.LocalizationValue(key), table: "Permissions")
    }

    private var keyPrefix: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }
}
