import Planner
import SwiftUI

struct ArrivalAlertsSection: View {
    @Environment(ArrivalAlertCenter.self) private var arrivalAlerts
    @Environment(NotificationScheduler.self) private var scheduler

    var body: some View {
        Section {
            Toggle(String(localized: "Settings.Toggle", table: "ArrivalAlerts"), isOn: Binding(
                get: { arrivalAlerts.isEnabled },
                set: { newValue in Task { await arrivalAlerts.setEnabled(newValue) } }
            ))
            .disabled(!arrivalAlerts.isSupported || !scheduler.isEnabled)
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
        .onAppear {
            arrivalAlerts.refreshAuthorization()
        }
    }
}
