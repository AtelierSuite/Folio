import Planner
import SwiftUI
import WidgetKit

struct MiniMonthWidget: Widget {
    static let kind = "MiniMonthWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: MonthConfigurationIntent.self,
            provider: FolioTimelineProvider<MonthConfigurationIntent>()
        ) { entry in
            MiniMonthWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(String(localized: "MiniMonth.Name", table: "Widgets"))
        .description(String(localized: "MiniMonth.Description", table: "Widgets"))
        .supportedFamilies(WidgetFamilies.miniMonth)
    }
}
