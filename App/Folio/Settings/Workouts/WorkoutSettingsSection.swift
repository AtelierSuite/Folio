import Planner
import SwiftUI

struct WorkoutSettingsSection: View {
    @Environment(\.platformCapabilities) private var capabilities
    @Environment(WorkoutStore.self) private var store
    @State private var recentWorkouts: [Workout]?

    var body: some View {
        if capabilities.supports(.workouts) && store.isAvailable {
            Section {
                WorkoutTimelineToggle()
                    .task(id: LoadKey(revision: store.revision, isShown: store.isShownOnTimeline)) {
                        recentWorkouts = store.isShownOnTimeline ? await store.recentWorkouts() : nil
                    }
                if store.isShownOnTimeline, let recentWorkouts {
                    WorkoutSummaryRows(recentWorkouts: recentWorkouts)
                }
            } footer: {
                Text(String(localized: "Settings.Footer", table: "Workouts"))
            }
        }
    }

    private struct LoadKey: Equatable {
        let revision: Int
        let isShown: Bool
    }
}
