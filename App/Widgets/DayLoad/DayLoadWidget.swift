import Planner
import SwiftUI
import WidgetKit

struct DayLoadWidget: Widget {
    static let kind = "DayLoadWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: DayLoadConfigurationIntent.self,
            provider: FolioTimelineProvider<DayLoadConfigurationIntent>()
        ) { entry in
            DayLoadWidgetView(entry: entry)
                .folioWidgetContainer()
        }
        .configurationDisplayName(String(localized: "DayLoad.Name", table: "Widgets"))
        .description(String(localized: "DayLoad.Description", table: "Widgets"))
        .supportedFamilies(WidgetFamilies.dayLoad)
        .contentMarginsDisabled()
    }
}
