import Planner
import SwiftUI

struct LeaveAlertStylePicker: View {
    @Environment(LeaveAlertCenter.self) private var leaveAlerts
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        Picker(String(localized: "Settings.AlertStyle", table: "LeaveAlerts"), selection: Binding(
            get: { leaveAlerts.ringsAsAlarm },
            set: { ringsAsAlarm in
                Task {
                    guard await permissionCenter.allowsTurningOn(ringsAsAlarm, needing: .alarms) else { return }
                    await leaveAlerts.setRingsAsAlarm(ringsAsAlarm)
                }
            }
        )) {
            Text(String(localized: "Settings.AlertStyle.Notification", table: "LeaveAlerts")).tag(false)
            Text(String(localized: "Settings.AlertStyle.Alarm", table: "LeaveAlerts")).tag(true)
        }
        .accessibilityIdentifier("LeaveAlertStylePicker")
        .onAppear {
            leaveAlerts.refreshAuthorization()
        }
    }
}
