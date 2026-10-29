import Planner
import SwiftUI
import WidgetKit

struct UpNextWidget: Widget {
    static let kind = "UpNextWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: UpNextConfigurationIntent.self,
            provider: FolioTimelineProvider<UpNextConfigurationIntent>()
        ) { entry in
            UpNextWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(String(localized: "UpNext.Name", table: "Widgets"))
        .description(String(localized: "UpNext.Description", table: "Widgets"))
        .supportedFamilies(WidgetFamilies.upNext)
    }
}
