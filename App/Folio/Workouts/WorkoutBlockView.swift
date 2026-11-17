import Planner
import SwiftUI

/// Workouts are shaded in one muted hue so they sit quietly behind events, like sleep.
struct WorkoutBlockView: View {
    let activity: WorkoutActivity
    let showsLabel: Bool

    var body: some View {
        Rectangle()
            .fill(Color.green.opacity(0.1))
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(Color.green.opacity(0.45))
                    .frame(width: 3)
            }
            .overlay(alignment: .topLeading) {
                if showsLabel {
                    WorkoutBlockLabel(activity: activity)
                }
            }
            .clipped()
    }
}

private struct WorkoutBlockLabel: View {
    let activity: WorkoutActivity

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: activity.systemImage)
            Text(activity.title)
                .lineLimit(1)
        }
        .font(.caption2.weight(.medium))
        .foregroundStyle(Color.green.opacity(0.85))
        .padding(.leading, 7)
        .padding(.trailing, 2)
        .padding(.top, 3)
    }
}
