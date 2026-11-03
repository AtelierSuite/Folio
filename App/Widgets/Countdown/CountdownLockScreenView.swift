import Planner
import SwiftUI

struct CountdownLockScreenView: View {
    let state: EventCountdownAttributes.ContentState
    let phase: CountdownPhase

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            WidgetColorBar(color: state.color)
            CountdownEventSummary(state: state)
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 2) {
                Text(phase.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                CountdownTimerText(phase: phase)
                    .font(.title.weight(.semibold))
            }
        }
        .padding(16)
    }
}
