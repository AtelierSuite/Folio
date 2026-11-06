import Planner
import SwiftUI
import WidgetKit

struct InboxWidget: Widget {
    static let kind = "InboxWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: InboxConfigurationIntent.self,
            provider: FolioTimelineProvider<InboxConfigurationIntent>()
        ) { entry in
            InboxWidgetView(entry: entry)
                .folioWidgetContainer()
        }
        .configurationDisplayName(String(localized: "Inbox.Name", table: "Widgets"))
        .description(String(localized: "Inbox.Description", table: "Widgets"))
        .supportedFamilies(WidgetFamilies.inbox)
        .contentMarginsDisabled()
    }
}
