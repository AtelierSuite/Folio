import Planner
import SwiftUI

struct WatchEventDateText: View {
    let event: CalendarEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(days)
            Text(WatchEventTimeText.description(of: event, at: .distantPast))
                .foregroundStyle(.secondary)
        }
        .font(.footnote)
    }

    /// All-day events end at the following midnight, so their last day is the one before it.
    private var days: String {
        let lastInstant = event.isAllDay ? event.endDate.addingTimeInterval(-1) : event.endDate
        let end = max(lastInstant, event.startDate)
        return (event.startDate..<end).formatted(.interval.weekday(.abbreviated).month(.abbreviated).day())
    }
}
