import SwiftUI

/// HealthKit hides read denial, so the same copy covers no workouts and no access.
struct WorkoutEmptyStateView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(String(localized: "Empty.Title", table: "Workouts"))
                .font(.headline)
            Text(String(localized: "Empty.Description", table: "Workouts"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("WorkoutEmptyState")
    }
}
