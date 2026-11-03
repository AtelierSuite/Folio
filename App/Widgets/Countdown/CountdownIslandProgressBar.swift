import Planner
import SwiftUI

struct CountdownIslandProgressBar: View {
    let phase: CountdownPhase
    let color: PlannerColor

    var body: some View {
        if let interval = phase.interval {
            ProgressView(timerInterval: interval, countsDown: true) {
                EmptyView()
            } currentValueLabel: {
                EmptyView()
            }
            .progressViewStyle(.linear)
            .tint(color.color)
            .padding(.horizontal, 6)
            .padding(.top, 4)
        }
    }
}
