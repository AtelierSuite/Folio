import SwiftUI
import WidgetKit

struct UpNextComplication: Widget {
    static let kind = "UpNextComplication"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: ComplicationConfigurationIntent.self,
            provider: ComplicationProvider(
                recommendationTitle: String(localized: "UpNext.Name", table: "Complications")
            )
        ) { entry in
            UpNextComplicationView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(String(localized: "UpNext.Name", table: "Complications"))
        .description(String(localized: "UpNext.Description", table: "Complications"))
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryCorner, .accessoryInline])
    }
}
