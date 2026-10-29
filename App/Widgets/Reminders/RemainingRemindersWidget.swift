import Planner
import SwiftUI
import WidgetKit

#if os(iOS)
struct RemainingRemindersWidget: Widget {
    static let kind = "RemainingRemindersWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: ReminderListSelectionIntent.self,
            provider: FolioTimelineProvider<ReminderListSelectionIntent>()
        ) { entry in
            RemainingRemindersView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(CalendarDeepLink.url(forDay: entry.date))
        }
        .configurationDisplayName(String(localized: "RemainingReminders.Name", table: "Widgets"))
        .description(String(localized: "RemainingReminders.Description", table: "Widgets"))
        .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}
#endif
