import Planner
import SwiftUI

struct SleepTimelineToggle: View {
    @Environment(SleepStore.self) private var store
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        Toggle(String(localized: "Settings.ShowOnTimeline", table: "Sleep"), isOn: Binding(
            get: { store.isShownOnTimeline },
            set: { store.setShownOnTimeline($0) }
        ))
        .disabled(permissionCenter.isMissingAccess(to: .health))
        .accessibilityIdentifier("SleepTimelineToggle")
    }
}
