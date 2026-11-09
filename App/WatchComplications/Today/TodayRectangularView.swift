import Planner
import SwiftUI
import WidgetKit

struct TodayRectangularView: View {
    private static let visibleLimit = 2

    let date: Date
    let events: [CalendarEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 4) {
                Text(date.formatted(.dateTime.weekday(.abbreviated).day()))
                    .font(.headline)
                    .widgetAccentable()
                Spacer(minLength: 0)
                if events.count > Self.visibleLimit {
                    Text(String(localized: "Today.More \(events.count - Self.visibleLimit)", table: "Complications"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            if events.isEmpty {
                Text(String(localized: "UpNext.Empty", table: "Complications"))
                    .foregroundStyle(.secondary)
            }
            ForEach(events.prefix(Self.visibleLimit)) { event in
                ComplicationEventLine(event: event)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
