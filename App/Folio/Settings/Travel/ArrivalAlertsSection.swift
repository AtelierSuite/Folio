import Planner
import SwiftUI

struct ArrivalAlertsSection: View {
    @Environment(ArrivalAlertCenter.self) private var arrivalAlerts
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        Section {
            Toggle(String(localized: "Settings.Toggle", table: "ArrivalAlerts"), isOn: Binding(
                get: { arrivalAlerts.isEnabled },
                set: { newValue in
                    Task {
                        guard await permissionCenter.allowsTurningOn(newValue, needing: .location) else { return }
                        await arrivalAlerts.setEnabled(newValue)
                    }
                }
            ))
            .disabled(!arrivalAlerts.isSupported || !scheduler.isEnabled || isMissingLocationAccess)
            .accessibilityIdentifier("ArrivalAlertsToggle")
            if arrivalAlerts.isSupported && arrivalAlerts.isEnabled {
                LocationAlertAccessRows(
                    authorization: arrivalAlerts.authorization,
                    isMonitoringAvailable: arrivalAlerts.isMonitoringAvailable,
                    table: "ArrivalAlerts"
                )
            }
        } header: {
            Text(String(localized: "Settings.Section", table: "ArrivalAlerts"))
        } footer: {
            Text(arrivalAlerts.isSupported
                 ? String(localized: "Settings.Footer", table: "ArrivalAlerts")
                 : String(localized: "Unsupported", table: "ArrivalAlerts"))
        }
        .onChange(of: permissionCenter.status(of: .location), initial: true) {
            arrivalAlerts.refreshAuthorization()
        }
    }

    private var isMissingLocationAccess: Bool {
        permissionCenter.isBlocked(.location)
    }
}
