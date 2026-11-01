import Planner
import SwiftUI

struct LeaveAlarmRows: View {
    @Environment(LeaveAlertCenter.self) private var leaveAlerts
    @Environment(\.platformCapabilities) private var capabilities
    @Environment(\.openURL) private var openURL

    var body: some View {
        if capabilities.supports(.alarms) {
            Toggle(String(localized: "Settings.RingsAsAlarm", table: "LeaveAlerts"), isOn: Binding(
                get: { leaveAlerts.ringsAsAlarm },
                set: { newValue in Task { await leaveAlerts.setRingsAsAlarm(newValue) } }
            ))
            .accessibilityIdentifier("LeaveAlarmToggle")
            if leaveAlerts.ringsAsAlarm && leaveAlerts.alarmAuthorization == .denied {
                Text(String(localized: "Settings.AlarmDenied", table: "LeaveAlerts"))
                    .foregroundStyle(.secondary)
                if let settingsURL = PermissionKind.alarms.settingsURL {
                    Button(String(localized: "Settings.AlarmDenied.OpenSettings", table: "LeaveAlerts")) {
                        openURL(settingsURL)
                    }
                }
            }
        }
    }
}
