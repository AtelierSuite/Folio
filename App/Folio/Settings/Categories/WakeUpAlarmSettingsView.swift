import Planner
import SwiftUI

struct WakeUpAlarmSettingsView: View {
    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        Form {
            WakeUpNextAlarmHero()
            PermissionPromptSection(
                kind: .alarms,
                message: String(localized: "Prompt.Alarms", table: "Permissions"),
                asksOnToggle: true
            )
            WakeUpAlarmSection()
        }
        .settingsCategoryStyle(.wakeUpAlarm)
        .task(id: accessStatuses) {
            await permissionCenter.refresh(.alarms)
            await wakeUpAlarms.replan()
        }
    }

    private var accessStatuses: [PermissionStatus?] {
        [permissionCenter.status(of: .alarms), permissionCenter.status(of: .location)]
    }
}
