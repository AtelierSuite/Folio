import Planner
import SwiftUI

struct WorkoutSettingsSection: View {
    @Environment(\.platformCapabilities) private var capabilities
    @Environment(WorkoutStore.self) private var store
    @State private var hasRecentWorkouts = true

    var body: some View {
        if capabilities.supports(.workouts) && store.isAvailable {
            Section {
                WorkoutTimelineToggle()
                    .task(id: LoadKey(revision: store.revision, isShown: store.isShownOnTimeline)) {
                        guard store.isShownOnTimeline else {
                            hasRecentWorkouts = true
                            return
                        }
                        hasRecentWorkouts = await !store.recentWorkouts().isEmpty
                    }
                if !hasRecentWorkouts {
                    WorkoutEmptyStateView()
                }
            }
        }
    }

    private struct LoadKey: Equatable {
        let revision: Int
        let isShown: Bool
    }
}
