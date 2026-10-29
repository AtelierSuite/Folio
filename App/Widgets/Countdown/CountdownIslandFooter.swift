import Planner
import SwiftUI

struct CountdownIslandFooter: View {
    let state: EventCountdownAttributes.ContentState
    let phase: CountdownPhase

    var body: some View {
        HStack {
            Text(phase.title)
            Spacer()
            Text(state.location.flatMap { $0.isEmpty ? nil : $0 } ?? WidgetEventTimeText.time(state.startDate))
                .lineLimit(1)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}
