import Planner
import SwiftUI

struct FocusLevelSettingsSection: View {
    @Environment(PermissionCenter.self) private var permissionCenter
    @AppStorage(FocusLevelSettings.isShownKey) private var isShown = false
    @AppStorage(FocusLevelSettings.bleedsUnderEventsKey) private var bleedsUnderEvents = true

    var body: some View {
        Section {
            Toggle(String(localized: "Settings.ShowOnCalendar", table: "FocusLevel"), isOn: Binding(
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
                Toggle(String(localized: "Settings.BleedsUnderEvents", table: "FocusLevel"), isOn: $bleedsUnderEvents)
                    .accessibilityIdentifier("FocusLevelBleedToggle")
            }
        } footer: {
            Text(String(localized: "Settings.Footer", table: "FocusLevel"))
        }
    }
}
