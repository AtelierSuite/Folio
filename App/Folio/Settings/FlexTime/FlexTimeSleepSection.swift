import Planner
import SwiftUI

struct FlexTimeSleepSection: View {
    @Environment(\.platformCapabilities) private var capabilities
    @Environment(SleepStore.self) private var sleepStore
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        Section {
            if isSleepAvailable {
                Toggle(String(localized: "Settings.UseSleep", table: "FlexTime"), isOn: Binding(
                    get: { sleepStore.informsFlexTime },
                    set: { informs in
                        Task {
                            guard await permissionCenter.allowsTurningOn(informs, needing: .health) else { return }
                            sleepStore.setInformsFlexTime(informs)
                        }
                    }
                ))
                .disabled(permissionCenter.isBlocked(.health))
                .accessibilityIdentifier("FlexTimeSleepToggle")
            }
        } header: {
            if isSleepAvailable {
                Text(String(localized: "Settings.Wake.Header", table: "FlexTime"))
            }
        } footer: {
            Text(isSleepAvailable
                 ? String(localized: "Settings.Sleep.Footer", table: "FlexTime")
                 : String(localized: "Settings.FirstOpen.Footer", table: "FlexTime"))
        }
    }

    private var isSleepAvailable: Bool {
        capabilities.supports(.sleep) && sleepStore.isAvailable
    }
}
