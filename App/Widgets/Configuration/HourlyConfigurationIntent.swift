import AppIntents
import Planner

struct HourlyConfigurationIntent: FolioWidgetIntent {
    static let title = LocalizedStringResource("Configuration.Calendars.Title", table: "Widgets")
    static let description = IntentDescription(
        LocalizedStringResource("Configuration.Calendars.Description", table: "Widgets")
    )

    @Parameter(title: LocalizedStringResource("Configuration.Calendars", table: "Widgets"))
    var calendars: [CalendarEntity]?

    nonisolated init() {}

    nonisolated var timelineTickInterval: TimeInterval? { 15 * 60 }

    nonisolated func snapshotRequest(at now: Date, calendar: Calendar) -> WidgetSnapshotRequest {
        .upcoming(from: now, calendar: calendar, calendars: calendars?.identifierSet)
    }
}
