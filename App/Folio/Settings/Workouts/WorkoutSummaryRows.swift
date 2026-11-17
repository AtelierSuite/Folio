import Planner
import SwiftUI

struct WorkoutSummaryRows: View {
    let recentWorkouts: [Workout]

    var body: some View {
        if let lastWorkout = recentWorkouts.last {
            LabeledContent(String(localized: "Settings.LastWorkout", table: "Workouts")) {
                Label(lastWorkout.activity.title, systemImage: lastWorkout.activity.systemImage)
                    .labelStyle(WorkoutSummaryLabelStyle())
            }
            .accessibilityIdentifier("WorkoutLastWorkout")
        } else {
            WorkoutEmptyStateView()
        }
    }
}

private struct WorkoutSummaryLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon
            configuration.title
        }
    }
}
