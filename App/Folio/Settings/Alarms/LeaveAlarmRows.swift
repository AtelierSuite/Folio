import Planner
import SwiftUI

struct LeaveAlarmRows: View {
    @Environment(LeaveAlertCenter.self) private var leaveAlerts
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        Toggle(String(localized: "Settings.RingsAsAlarm", table: "LeaveAlerts"), isOn: Binding(
            get: { leaveAlerts.ringsAsAlarm },
            set: { newValue in
                Task {
                    guard await permissionCenter.allowsTurningOn(newValue, needing: .alarms) else { return }
                    await leaveAlerts.setRingsAsAlarm(newValue)
                }
            }
        ))
        .accessibilityIdentifier("LeaveAlarmToggle")
    }
}
