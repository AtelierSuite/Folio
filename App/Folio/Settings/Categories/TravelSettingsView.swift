import Planner
import SwiftUI

struct TravelSettingsView: View {
    @Environment(LeaveAlertCenter.self) private var leaveAlerts
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        Form {
            TravelNotificationsPromptSection()
            PermissionPromptSection(
                kind: .location,
                message: String(localized: "Prompt.LocationAlerts", table: "Permissions"),
                asksOnToggle: true
            )
            LeaveAlertsSection()
            ArrivalAlertsSection()
            LeaveBySettingsSection()
        }
        .settingsCategoryStyle(.travel)
        .task(id: permissionCenter.status(of: .alarms)) {
            await leaveAlerts.replan()
        }
    }
}
