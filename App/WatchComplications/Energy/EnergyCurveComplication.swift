import Planner
import SwiftUI
import WidgetKit

struct EnergyCurveComplication: Widget {
    static let kind = "EnergyCurveComplication"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: ComplicationConfigurationIntent.self,
            provider: EnergyComplicationProvider(
                recommendationTitle: String(localized: "EnergyCurve.Name", table: "Complications")
            )
        ) { entry in
            EnergyCurveCircularView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(CalendarDeepLink.url(forDay: entry.date))
        }
        .configurationDisplayName(String(localized: "EnergyCurve.Name", table: "Complications"))
        .description(String(localized: "EnergyCurve.Description", table: "Complications"))
        .supportedFamilies([.accessoryCircular])
    }
}
