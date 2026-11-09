import Planner
import SwiftUI
import WidgetKit

struct TimelineComplication: Widget {
    static let kind = "TimelineComplication"
    static let hourCount = 3
    static let laneLimit = 2
    /// Moves the window and the now line along between event changes.
    private static let tickInterval: TimeInterval = 15 * 60

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: ComplicationConfigurationIntent.self,
            provider: ComplicationProvider(
                recommendationTitle: String(localized: "Timeline.Name", table: "Complications"),
                tickInterval: Self.tickInterval
            )
        ) { entry in
            TimelineComplicationView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(CalendarDeepLink.url(forDay: entry.date))
        }
        .configurationDisplayName(String(localized: "Timeline.Name", table: "Complications"))
        .description(String(localized: "Timeline.Description", table: "Complications"))
        .supportedFamilies([.accessoryRectangular])
    }
}
