import Planner
import SwiftUI

struct EnergyLevelSettingsSection: View {
    @Environment(PermissionCenter.self) private var permissionCenter
    @AppStorage(EnergyLevelSettings.isShownKey) private var isShown = false
    @AppStorage(EnergyLevelSettings.bleedsUnderEventsKey) private var bleedsUnderEvents = true

    var body: some View {
        Section {
            Toggle(String(localized: "Settings.ShowOnCalendar", table: "EnergyLevel"), isOn: Binding(
                get: { isShown },
                set: { newValue in
                    Task {
                        guard await permissionCenter.allowsTurningOn(newValue, needing: .health) else { return }
                        isShown = newValue
                    }
                }
            ))
            .disabled(permissionCenter.isBlocked(.health))
            .accessibilityIdentifier("FocusLevelToggle")
            if isShown {
                Toggle(String(localized: "Settings.BleedsUnderEvents", table: "EnergyLevel"), isOn: $bleedsUnderEvents)
                    .accessibilityIdentifier("FocusLevelBleedToggle")
            }
        } footer: {
            Text(String(localized: "Settings.Footer", table: "EnergyLevel"))
        }
    }
}
