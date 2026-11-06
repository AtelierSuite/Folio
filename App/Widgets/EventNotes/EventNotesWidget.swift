import Planner
import SwiftUI
import WidgetKit

struct EventNotesWidget: Widget {
    static let kind = "EventNotesWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: EventNotesConfigurationIntent.self,
            provider: FolioTimelineProvider<EventNotesConfigurationIntent>()
        ) { entry in
            EventNotesWidgetView(entry: entry)
                .folioWidgetContainer()
        }
        .configurationDisplayName(String(localized: "EventNotes.Name", table: "Widgets"))
        .description(String(localized: "EventNotes.Description", table: "Widgets"))
        .supportedFamilies(WidgetFamilies.eventNotes)
        .contentMarginsDisabled()
    }
}
