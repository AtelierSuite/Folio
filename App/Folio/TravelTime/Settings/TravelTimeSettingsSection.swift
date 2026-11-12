import Planner
import SwiftUI

struct TravelTimeSettingsSection: View {
    @Environment(TravelTimeStore.self) private var travelTime
    @Environment(PermissionCenter.self) private var permissions

    var body: some View {
        Section {
            Toggle(String(localized: "Settings.Toggle", table: "TravelTime"), isOn: isEnabled)
                .accessibilityIdentifier("TravelTimeToggle")
            if travelTime.isEnabled {
                TravelTransportPicker(selection: Binding(
                    get: { travelTime.transport },
                    set: { travelTime.setTransport($0) }
                ), accessibilityIdentifier: "TravelTimeTransportPicker")
            }
        } header: {
            Text(String(localized: "Settings.Header", table: "TravelTime"))
        } footer: {
            Text(String(localized: "Settings.Footer", table: "TravelTime"))
        }
        .disabled(permissions.isBlocked(.location))
        .onChange(of: permissions.status(of: .location)) {
            travelTime.locationAuthorizationDidChange()
        }
    }

    private var isEnabled: Binding<Bool> {
        Binding {
            travelTime.isEnabled
        } set: { isEnabled in
            Task {
                guard await permissions.allowsTurningOn(isEnabled, needing: .location) else { return }
                travelTime.setEnabled(isEnabled)
            }
        }
    }
}
