import Planner
import SwiftUI
import WidgetKit

struct TodayComplication: Widget {
    static let kind = "TodayComplication"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: ComplicationConfigurationIntent.self,
            provider: ComplicationProvider(
                recommendationTitle: String(localized: "Today.Name", table: "Complications")
            )
        ) { entry in
            TodayComplicationView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(CalendarDeepLink.url(forDay: entry.date))
        }
        .configurationDisplayName(String(localized: "Today.Name", table: "Complications"))
        .description(String(localized: "Today.Description", table: "Complications"))
        .supportedFamilies([.accessoryRectangular, .accessoryCircular])
    }
}
