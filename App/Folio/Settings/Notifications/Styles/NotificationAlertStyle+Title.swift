import Planner
import SwiftUI

extension NotificationAlertStyle {
    var title: String {
        switch self {
        case .standard: String(localized: "Style.Standard", table: "NotificationStyles")
        case .timeSensitive: String(localized: "Style.TimeSensitive", table: "NotificationStyles")
        case .alarm: String(localized: "Style.Alarm", table: "NotificationStyles")
        }
    }

    var systemImage: String {
        switch self {
        case .standard: "bell"
        case .timeSensitive: "clock.badge.exclamationmark"
        case .alarm: "alarm"
        }
    }
}
