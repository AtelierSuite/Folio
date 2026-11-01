import Planner
import SwiftUI

struct WakeUpAlarmDeniedRows: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Text(String(localized: "Denied", table: "WakeUpAlarms"))
            .foregroundStyle(.secondary)
        if let settingsURL = PermissionKind.alarms.settingsURL {
            Button(String(localized: "Denied.OpenSettings", table: "WakeUpAlarms")) {
                openURL(settingsURL)
            }
        }
    }
}
