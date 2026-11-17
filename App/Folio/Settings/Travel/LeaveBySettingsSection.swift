import Planner
import SwiftUI

/// Leave By turns itself on while its widget is placed, so this only appears when location access stops it working.
struct LeaveBySettingsSection: View {
    @Environment(ArrivalAlertCenter.self) private var arrivalAlerts
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        Group {
            if arrivalAlerts.isLeaveByEnabled {
                AlwaysLocationPromptSection(
                    authorization: arrivalAlerts.authorization,
                    isMonitoringAvailable: arrivalAlerts.isMonitoringAvailable,
                    table: "LeaveBy"
                )
            }
        }
        .onChange(of: permissionCenter.status(of: .location), initial: true) {
            arrivalAlerts.refreshAuthorization()
        }
    }
}
