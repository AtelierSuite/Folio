import Planner
import SwiftUI
import WidgetKit

struct EnergyComplication: Widget {
    static let kind = "EnergyComplication"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: ComplicationConfigurationIntent.self,
            provider: EnergyComplicationProvider()
        ) { entry in
            EnergyComplicationView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(CalendarDeepLink.url(forDay: entry.date))
        }
        .configurationDisplayName(String(localized: "Energy.Name", table: "Complications"))
        .description(String(localized: "Energy.Description", table: "Complications"))
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryCorner, .accessoryInline])
    }
}
