import Planner
import SwiftUI
import WidgetKit

/// The date, with a dot for each event still to come today.
struct TodayCircularView: View {
    private static let dotLimit = 4

    let date: Date
    let events: [CalendarEvent]

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.system(size: 11, weight: .semibold))
                    .textCase(.uppercase)
                    .widgetAccentable()
                Text(date.formatted(.dateTime.day()))
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                HStack(spacing: 2) {
                    ForEach(events.prefix(Self.dotLimit)) { event in
                        Circle()
                            .fill(event.color.color)
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(String(localized: "Today.Remaining \(events.count)", table: "Complications"))
    }
}
