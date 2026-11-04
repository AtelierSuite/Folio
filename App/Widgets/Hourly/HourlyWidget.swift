import Planner
import SwiftUI
import WidgetKit

struct HourlyWidget: Widget {
    static let kind = "HourlyWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: HourlyConfigurationIntent.self,
            provider: FolioTimelineProvider<HourlyConfigurationIntent>()
        ) { entry in
            HourlyWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(String(localized: "Hourly.Name", table: "Widgets"))
        .description(String(localized: "Hourly.Description", table: "Widgets"))
        .supportedFamilies(WidgetFamilies.hourly)
        .contentMarginsDisabled()
    }
}
