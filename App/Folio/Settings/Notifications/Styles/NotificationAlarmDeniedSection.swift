import Planner
import SwiftUI

struct NotificationAlarmDeniedSection: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            Text(String(localized: "AlarmDenied", table: "NotificationStyles"))
                .foregroundStyle(.secondary)
            if let settingsURL = PermissionKind.alarms.settingsURL {
                Button(String(localized: "AlarmDenied.OpenSettings", table: "NotificationStyles")) {
                    openURL(settingsURL)
                }
            }
        }
    }
}
