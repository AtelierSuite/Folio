#if os(iOS)
import Planner
import SwiftUI
import WidgetKit

struct LeaveByWidget: Widget {
    static let kind = "LeaveByWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: LeaveByConfigurationIntent.self,
            provider: FolioTimelineProvider<LeaveByConfigurationIntent>()
        ) { entry in
            LeaveByWidgetView(entry: entry)
                .folioWidgetContainer()
        }
        .configurationDisplayName(String(localized: "LeaveBy.Name", table: "Widgets"))
        .description(String(localized: "LeaveBy.Description", table: "Widgets"))
        .supportedFamilies(WidgetFamilies.leaveBy)
    }
}
#endif
