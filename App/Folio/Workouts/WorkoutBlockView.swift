import Planner
import SwiftUI

/// Workouts are shaded in one muted hue so they sit quietly behind events, like sleep.
struct WorkoutBlockView: View {
    var body: some View {
        Rectangle()
            .fill(Color(.lime).opacity(0.1))
            .overlay(alignment: .trailing) {
                Rectangle()
                    .fill(Color(.lime).opacity(0.45))
                    .frame(width: 3)
            }
            .clipped()
    }
}
