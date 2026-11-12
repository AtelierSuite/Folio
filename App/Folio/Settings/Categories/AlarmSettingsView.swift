import Planner
import SwiftUI

struct AlarmSettingsView: View {
    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms
    @Environment(LeaveAlertCenter.self) private var leaveAlerts
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        Form {
            PermissionPromptSection(
                kind: .alarms,
                message: String(localized: "Prompt.Alarms", table: "Permissions")
            )
            PermissionPromptSection(
                kind: .location,
                message: String(localized: "Prompt.WakeUpTravelTime", table: "Permissions")
            )
            WakeUpAlarmSection()
            LeaveAlarmSection()
        }
        .settingsCategoryStyle(.alarms)
        .task(id: accessStatuses) {
            await permissionCenter.refresh(.alarms)
            await wakeUpAlarms.replan()
            await leaveAlerts.replan()
        }
    }

    private var accessStatuses: [PermissionStatus?] {
        [permissionCenter.status(of: .alarms), permissionCenter.status(of: .location)]
    }
}
