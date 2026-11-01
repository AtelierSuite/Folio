import Planner
import SwiftUI

struct TravelTimeSettingsSection: View {
    @Environment(TravelTimeStore.self) private var travelTime
    @Environment(PermissionCenter.self) private var permissions

    var body: some View {
        let status = permissions.status(of: .location) ?? .notDetermined
        Section {
            Toggle(String(localized: "Settings.Toggle", table: "TravelTime"), isOn: isEnabled)
                .accessibilityIdentifier("TravelTimeToggle")
            if travelTime.isEnabled {
                TravelTransportPicker(selection: Binding(
                    get: { travelTime.transport },
                    set: { travelTime.setTransport($0) }
                ), accessibilityIdentifier: "TravelTimeTransportPicker")
                if status.canBeFixedInSettings {
                    PermissionActionButton(kind: .location, status: status)
                }
            }
        } header: {
            Text(String(localized: "Settings.Header", table: "TravelTime"))
        } footer: {
            if travelTime.isEnabled && (status.canBeFixedInSettings || status == .restricted) {
                Text(String(localized: "Settings.LocationDenied", table: "TravelTime"))
            } else {
                Text(String(localized: "Settings.Footer", table: "TravelTime"))
            }
        }
    }

    private var isEnabled: Binding<Bool> {
        Binding {
            travelTime.isEnabled
        } set: { isEnabled in
            travelTime.setEnabled(isEnabled)
            guard isEnabled else { return }
            Task {
                await permissions.request(.location)
                travelTime.locationAuthorizationDidChange()
            }
        }
    }
}
