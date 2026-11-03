import Planner
import SwiftUI

struct CountdownIslandEventSummary: View {
    let state: EventCountdownAttributes.ContentState

    var body: some View {
        HStack(spacing: 8) {
            WidgetColorBar(color: state.color)
            VStack(alignment: .leading, spacing: 1) {
                Text(state.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.leading, 6)
    }

    private var subtitle: String {
        if let location = state.location, !location.isEmpty {
            return location
        }
        let start = WidgetEventTimeText.time(state.startDate)
        guard let endDate = state.endDate else { return start }
        return "\(start) – \(WidgetEventTimeText.time(endDate))"
    }
}
