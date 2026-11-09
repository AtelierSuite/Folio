import Planner
import SwiftUI

struct WatchEventRow: View {
    let event: CalendarEvent
    let now: Date

    var body: some View {
        HStack(spacing: 8) {
            Capsule()
                .fill(event.color.color)
                .frame(width: 4)
            VStack(alignment: .leading, spacing: 1) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(2)
                WatchEventTimeText(event: event, now: now)
                    .font(.caption)
                    .foregroundStyle(isOngoing ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                if let location = event.location, !location.isEmpty {
                    Text(location)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private var isOngoing: Bool {
        !event.isAllDay && event.startDate <= now && now < event.endDate
    }
}
