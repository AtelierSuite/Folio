import AppIntents
import Planner

struct MonthConfigurationIntent: FolioWidgetIntent {
    static let title = LocalizedStringResource("Configuration.Calendars.Title", table: "Widgets")
    static let description = IntentDescription(
        LocalizedStringResource("Configuration.Calendars.Description", table: "Widgets")
    )

    @Parameter(title: LocalizedStringResource("Configuration.Calendars", table: "Widgets"))
    var calendars: [CalendarEntity]?

    nonisolated init() {}

    nonisolated func snapshotRequest(at now: Date, calendar: Calendar) -> WidgetSnapshotRequest {
        .month(containing: now, calendar: calendar, calendars: calendars?.identifierSet)
    }
}
