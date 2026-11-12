import Planner
import SwiftUI

struct LeaveAlertsSection: View {
    @Environment(LeaveAlertCenter.self) private var leaveAlerts
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        Section {
            Toggle(String(localized: "Settings.Toggle", table: "LeaveAlerts"), isOn: Binding(
                get: { leaveAlerts.isEnabled },
                set: { newValue in
                    Task {
                        guard await permissionCenter.allowsTurningOn(newValue, needing: .location) else { return }
                        await leaveAlerts.setEnabled(newValue)
                    }
                }
            ))
            .disabled(!leaveAlerts.isSupported || !scheduler.isEnabled || isMissingLocationAccess)
            .accessibilityIdentifier("LeaveAlertsToggle")
            if leaveAlerts.isSupported && leaveAlerts.isEnabled {
                TravelTransportPicker(selection: Binding(
                    get: { leaveAlerts.transport },
                    set: { newValue in Task { await leaveAlerts.setTransport(newValue) } }
                ), accessibilityIdentifier: "TravelTransportPicker")
                .disabled(isMissingLocationAccess)
                LocationAlertAccessRows(authorization: leaveAlerts.authorization, table: "LeaveAlerts")
            }
        } header: {
            Text(String(localized: "Settings.Section", table: "LeaveAlerts"))
        } footer: {
            Text(leaveAlerts.isSupported
                 ? String(localized: "Settings.Footer", table: "LeaveAlerts")
                 : String(localized: "Unsupported", table: "LeaveAlerts"))
        }
        .onChange(of: permissionCenter.status(of: .location), initial: true) {
            leaveAlerts.refreshAuthorization()
        }
    }

    private var isMissingLocationAccess: Bool {
        permissionCenter.isBlocked(.location)
    }
}
