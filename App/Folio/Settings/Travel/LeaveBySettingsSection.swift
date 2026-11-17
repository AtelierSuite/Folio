import Planner
import SwiftUI

/// Leave By turns itself on while its widget is placed, so this only appears when location access stops it working.
struct LeaveBySettingsSection: View {
    @Environment(ArrivalAlertCenter.self) private var arrivalAlerts
    @Environment(PermissionCenter.self) private var permissionCenter

    private var needsAttention: Bool {
        arrivalAlerts.isLeaveByEnabled
            && (arrivalAlerts.authorization == .whenInUse || !arrivalAlerts.isMonitoringAvailable)
    }

    var body: some View {
        Group {
            if needsAttention {
                Section(String(localized: "Settings.Section", table: "LeaveBy")) {
                    LocationAlertAccessRows(
                        authorization: arrivalAlerts.authorization,
                        isMonitoringAvailable: arrivalAlerts.isMonitoringAvailable,
                        table: "LeaveBy"
                    )
                }
            }
        }
        .onChange(of: permissionCenter.status(of: .location), initial: true) {
            arrivalAlerts.refreshAuthorization()
        }
    }
}
