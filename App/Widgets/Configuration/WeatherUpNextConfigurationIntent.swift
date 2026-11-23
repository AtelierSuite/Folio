import AppIntents
import Planner

#if os(iOS)
struct WeatherUpNextConfigurationIntent: FolioWidgetIntent {
    static let title = LocalizedStringResource("Configuration.Calendars.Title", table: "Widgets")
    static let description = IntentDescription(
        LocalizedStringResource("Configuration.Calendars.Description", table: "Widgets")
    )

    @Parameter(title: LocalizedStringResource("Configuration.Calendars", table: "Widgets"))
    var calendars: [CalendarEntity]?

    @Parameter(title: LocalizedStringResource("Configuration.ShowDetails", table: "Widgets"), default: true)
    var showsEventDetails: Bool

    nonisolated init() {}

    nonisolated var showsDetails: Bool { showsEventDetails }

    nonisolated func snapshotRequest(at now: Date, calendar: Calendar) -> WidgetSnapshotRequest {
        .upcoming(from: now, calendar: calendar, calendars: calendars?.identifierSet, includesWeather: true)
    }
}
#endif
