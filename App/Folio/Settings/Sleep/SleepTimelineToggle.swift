import Planner
import SwiftUI

struct SleepTimelineToggle: View {
    @Environment(SleepStore.self) private var store
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        Toggle(String(localized: "Settings.ShowOnTimeline", table: "Sleep"), isOn: Binding(
            get: { store.isShownOnTimeline },
            set: { isShown in
                Task {
                    guard await permissionCenter.allowsTurningOn(isShown, needing: .health) else { return }
                    store.setShownOnTimeline(isShown)
                }
            }
        ))
        .disabled(permissionCenter.isBlocked(.health))
        .accessibilityIdentifier("SleepTimelineToggle")
    }
}
