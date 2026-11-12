import Planner
import SwiftUI

/// Health access is only requested the first time sleep is turned on for Flex Time.
struct FlexTimeSleepSection: View {
    @Environment(\.platformCapabilities) private var capabilities
    @Environment(SleepStore.self) private var sleepStore
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        Section {
            if isSleepAvailable {
                Toggle(String(localized: "Settings.UseSleep", table: "FlexTime"), isOn: Binding(
                    get: { sleepStore.informsFlexTime },
                    set: { usesSleep in
                        Task { await setUsesSleep(usesSleep) }
                    }
                ))
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

    private func setUsesSleep(_ usesSleep: Bool) async {
        if usesSleep {
            await permissionCenter.request(.health)
        }
        sleepStore.setInformsFlexTime(usesSleep)
    }
}
