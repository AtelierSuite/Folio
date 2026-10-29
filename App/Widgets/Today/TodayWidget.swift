import Planner
import SwiftUI
import WidgetKit

struct TodayWidget: Widget {
    static let kind = "TodayWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: AgendaConfigurationIntent.self,
            provider: FolioTimelineProvider<AgendaConfigurationIntent>()
        ) { entry in
            TodayWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(String(localized: "Today.Name", table: "Widgets"))
        .description(String(localized: "Today.Description", table: "Widgets"))
        .supportedFamilies(WidgetFamilies.today)
    }
}
