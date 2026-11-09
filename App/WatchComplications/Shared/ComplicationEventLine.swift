import Planner
import SwiftUI
import WidgetKit

/// One event in a list: a colour bar, its start time and title.
struct ComplicationEventLine: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 4) {
            Capsule()
                .fill(event.color.color)
                .frame(width: 3, height: 12)
                .widgetAccentable()
            Text(verbatim: time)
                .foregroundStyle(.secondary)
            Text(event.title)
                .privacySensitive()
        }
        .lineLimit(1)
    }

    private var time: String {
        event.isAllDay
            ? String(localized: "Event.AllDay", table: "WatchShared")
            : WatchEventTimeText.clock(event.startDate)
    }
}
