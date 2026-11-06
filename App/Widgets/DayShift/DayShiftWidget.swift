import Planner
import SwiftUI
import WidgetKit

struct DayShiftWidget: Widget {
    static let kind = "DayShiftWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: DayShiftConfigurationIntent.self,
            provider: FolioTimelineProvider<DayShiftConfigurationIntent>()
        ) { entry in
            DayShiftWidgetView(entry: entry)
                .folioWidgetContainer()
        }
        .configurationDisplayName(String(localized: "DayShift.Name", table: "Widgets"))
        .description(String(localized: "DayShift.Description", table: "Widgets"))
        .supportedFamilies(WidgetFamilies.dayShift)
    }
}
