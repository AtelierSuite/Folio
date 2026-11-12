import Planner
import SwiftUI

struct LeaveAlarmRows: View {
    @Environment(LeaveAlertCenter.self) private var leaveAlerts

    var body: some View {
        Toggle(String(localized: "Settings.RingsAsAlarm", table: "LeaveAlerts"), isOn: Binding(
            get: { leaveAlerts.ringsAsAlarm },
            set: { newValue in Task { await leaveAlerts.setRingsAsAlarm(newValue) } }
        ))
        .accessibilityIdentifier("LeaveAlarmToggle")
    }
}
