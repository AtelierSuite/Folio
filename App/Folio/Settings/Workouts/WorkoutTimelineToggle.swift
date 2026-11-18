import Planner
import SwiftUI

struct WorkoutTimelineToggle: View {
    @Environment(WorkoutStore.self) private var store
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        Toggle(String(localized: "Settings.ShowOnCalendar", table: "Workouts"), isOn: Binding(
            get: { store.isShownOnTimeline },
            set: { isShown in
                Task { await setShown(isShown) }
            }
        ))
        .disabled(permissionCenter.isBlocked(.health))
        .accessibilityIdentifier("WorkoutTimelineToggle")
    }

    private func setShown(_ isShown: Bool) async {
        if isShown {
            await store.requestAccessIfNeeded()
        }
        store.setShownOnTimeline(isShown)
    }
}
