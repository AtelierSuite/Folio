import Planner
import SwiftUI
import WidgetKit

#if os(iOS)
struct WeatherUpNextWidget: Widget {
    static let kind = "WeatherUpNextWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: WeatherUpNextConfigurationIntent.self,
            provider: FolioTimelineProvider<WeatherUpNextConfigurationIntent>()
        ) { entry in
            WeatherUpNextWidgetView(entry: entry)
                .folioWidgetContainer()
        }
        .configurationDisplayName(String(localized: "WeatherUpNext.Name", table: "Widgets"))
        .description(String(localized: "WeatherUpNext.Description", table: "Widgets"))
        .supportedFamilies([.accessoryRectangular, .accessoryInline])
    }
}
#endif
