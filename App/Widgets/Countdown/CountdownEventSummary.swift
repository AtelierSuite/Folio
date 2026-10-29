import Planner
import SwiftUI

struct CountdownEventSummary: View {
    let state: EventCountdownAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(state.title)
                .font(.headline)
                .lineLimit(2)
            Text(timeRange)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let location = state.location, !location.isEmpty {
                Text(location)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    private var timeRange: String {
        let start = WidgetEventTimeText.time(state.startDate)
        guard let endDate = state.endDate else { return start }
        return "\(start) – \(WidgetEventTimeText.time(endDate))"
    }
}
