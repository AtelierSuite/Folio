import Planner
import SwiftUI

struct CountdownIslandTimer: View {
    let phase: CountdownPhase
    let color: PlannerColor

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            if phase.interval != nil {
                Text(phase.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            CountdownTimerText(phase: phase)
                .font(.title2.weight(.semibold))
                .foregroundStyle(color.color)
        }
        .padding(.trailing, 6)
    }
}
