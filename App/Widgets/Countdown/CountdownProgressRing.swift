import Planner
import SwiftUI

struct CountdownProgressRing: View {
    let phase: CountdownPhase
    let color: PlannerColor

    var body: some View {
        if let interval = phase.interval {
            ProgressView(timerInterval: interval, countsDown: true) {
                EmptyView()
            } currentValueLabel: {
                EmptyView()
            }
            .progressViewStyle(.circular)
            .tint(color.color)
        } else {
            Image(systemName: "calendar")
                .foregroundStyle(color.color)
        }
    }
}
