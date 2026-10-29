import Planner
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension PermissionKind {
    var settingsURL: URL? {
        #if os(macOS)
        URL(string: macSettingsPath)
        #else
        URL(string: self == .notifications
            ? UIApplication.openNotificationSettingsURLString
            : UIApplication.openSettingsURLString)
        #endif
    }

    #if os(macOS)
    private var macSettingsPath: String {
        let privacy = "x-apple.systempreferences:com.apple.preference.security"
        return switch self {
        case .calendar: "\(privacy)?Privacy_Calendars"
        case .reminders: "\(privacy)?Privacy_Reminders"
        case .location: "\(privacy)?Privacy_LocationServices"
        case .notifications: "x-apple.systempreferences:com.apple.Notifications-Settings.extension"
        case .health, .alarms: privacy
        }
    }
    #endif
}
