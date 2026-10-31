import Planner
import SwiftUI

struct LeaveAlertsSection: View {
    @Environment(LeaveAlertCenter.self) private var leaveAlerts
    @Environment(NotificationScheduler.self) private var scheduler

    var body: some View {
        Section {
            Toggle(String(localized: "Settings.Toggle", table: "LeaveAlerts"), isOn: Binding(
                get: { leaveAlerts.isEnabled },
                set: { newValue in Task { await leaveAlerts.setEnabled(newValue) } }
            ))
            .disabled(!leaveAlerts.isSupported || !scheduler.isEnabled)
            .accessibilityIdentifier("LeaveAlertsToggle")
            if leaveAlerts.isSupported && leaveAlerts.isEnabled {
                TravelTransportPicker()
                LocationAlertAccessRows(authorization: leaveAlerts.authorization, table: "LeaveAlerts")
            }
        } header: {
            Text(String(localized: "Settings.Section", table: "LeaveAlerts"))
        } footer: {
            Text(leaveAlerts.isSupported
                 ? String(localized: "Settings.Footer", table: "LeaveAlerts")
                 : String(localized: "Unsupported", table: "LeaveAlerts"))
        }
        .onAppear {
            leaveAlerts.refreshAuthorization()
        }
    }
}
