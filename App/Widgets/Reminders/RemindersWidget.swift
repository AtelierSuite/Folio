import Planner
import SwiftUI
import WidgetKit

struct RemindersWidget: Widget {
    static let kind = "RemindersWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: ReminderListSelectionIntent.self,
            provider: FolioTimelineProvider<ReminderListSelectionIntent>()
        ) { entry in
            RemindersWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(String(localized: "Reminders.Name", table: "Widgets"))
        .description(String(localized: "Reminders.Description", table: "Widgets"))
        .supportedFamilies(WidgetFamilies.reminders)
    }
}
