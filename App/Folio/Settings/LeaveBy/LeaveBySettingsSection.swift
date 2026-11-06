import Planner
import SwiftUI

struct LeaveBySettingsSection: View {
    @Environment(ArrivalAlertCenter.self) private var arrivalAlerts

    var body: some View {
        if arrivalAlerts.isSupported {
            Section {
                Toggle(String(localized: "Settings.Toggle", table: "LeaveBy"), isOn: Binding(
                    get: { arrivalAlerts.isLeaveByEnabled },
                    set: { newValue in Task { await arrivalAlerts.setLeaveByEnabled(newValue) } }
                ))
                .accessibilityIdentifier("LeaveByToggle")
                if arrivalAlerts.isLeaveByEnabled {
                    LocationAlertAccessRows(
                        authorization: arrivalAlerts.authorization,
                        isMonitoringAvailable: arrivalAlerts.isMonitoringAvailable,
                        table: "LeaveBy"
                    )
                }
            } header: {
                Text(String(localized: "Settings.Section", table: "LeaveBy"))
            } footer: {
                Text(String(localized: "Settings.Footer", table: "LeaveBy"))
            }
            .onAppear {
                arrivalAlerts.refreshAuthorization()
            }
        }
    }
}
