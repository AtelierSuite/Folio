import Planner
import SwiftUI

/// Health access is only requested the first time sleep is turned on.
struct SleepTimelineToggle: View {
    @Environment(SleepStore.self) private var store
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        Toggle(String(localized: "Settings.ShowOnTimeline", table: "Sleep"), isOn: Binding(
            get: { store.isShownOnTimeline },
            set: { isShown in
                Task { await setShown(isShown) }
            }
        ))
        .accessibilityIdentifier("SleepTimelineToggle")
    }

    private func setShown(_ isShown: Bool) async {
        if isShown {
            await permissionCenter.request(.health)
        }
        store.setShownOnTimeline(isShown)
    }
}
