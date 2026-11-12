import Planner
import SwiftUI

struct LeaveAlarmSection: View {
    @Environment(LeaveAlertCenter.self) private var leaveAlerts
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(PermissionCenter.self) private var permissionCenter

    private var isAvailable: Bool {
        leaveAlerts.isSupported && leaveAlerts.isEnabled && scheduler.isEnabled
            && !permissionCenter.isBlocked(.alarms)
    }

    var body: some View {
        Section {
            LeaveAlarmRows()
                .disabled(!isAvailable)
        } header: {
            Text(String(localized: "Settings.Section", table: "LeaveAlerts"))
        } footer: {
            Text(String(localized: "Settings.AlarmFooter", table: "LeaveAlerts"))
        }
        .onAppear {
            leaveAlerts.refreshAuthorization()
        }
    }
}
