import Planner
import SwiftUI

struct WatchAllDayStrip: View {
    static let visibleLimit = 2

    let days: TimelineDays
    let events: [CalendarEvent]

    var body: some View {
        if !events.isEmpty {
            HStack(alignment: .top, spacing: 2) {
                Color.clear
                    .frame(width: WatchHourGrid.labelWidth, height: 1)
                ForEach(days.intervals, id: \.start) { interval in
                    WatchAllDayColumn(events: events.filter { $0.overlaps(interval) }, limit: Self.visibleLimit)
                        .frame(maxWidth: .infinity, alignment: .top)
                }
            }
        }
    }
}

private struct WatchAllDayColumn: View {
    let events: [CalendarEvent]
    let limit: Int

    var body: some View {
        VStack(spacing: 2) {
            ForEach(events.prefix(limit)) { event in
                NavigationLink(value: event) {
                    Text(event.title)
                        .font(.system(size: 11, weight: .semibold))
                        .lineLimit(1)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(event.color.color)
                        .background(event.color.color.opacity(0.3), in: RoundedRectangle(cornerRadius: 4))
                }
                .buttonStyle(.plain)
            }
            if events.count > limit {
                Text(verbatim: "+\(events.count - limit)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
