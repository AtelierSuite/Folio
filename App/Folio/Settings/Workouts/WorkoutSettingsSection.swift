import Planner
import SwiftUI

struct WorkoutSettingsSection: View {
    @Environment(\.platformCapabilities) private var capabilities
    @Environment(WorkoutStore.self) private var store

    var body: some View {
        if capabilities.supports(.workouts) && store.isAvailable {
            Section {
                WorkoutTimelineToggle()
            }
        }
    }
}
