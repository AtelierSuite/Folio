import AppIntents
import Planner

struct DayShiftConfigurationIntent: FolioWidgetIntent {
    static let title = LocalizedStringResource("Configuration.Calendars.Title", table: "Widgets")
    static let description = IntentDescription(
        LocalizedStringResource("Configuration.Calendars.Description", table: "Widgets")
    )

    @Parameter(title: LocalizedStringResource("Configuration.Calendars", table: "Widgets"))
    var calendars: [CalendarEntity]?

    nonisolated init() {}

    nonisolated func snapshotRequest(at now: Date, calendar: Calendar) -> WidgetSnapshotRequest {
        .upcoming(
            from: now,
            calendar: calendar,
            calendars: calendars?.identifierSet,
            includesWeather: true,
            includesAlarms: true
        )
    }

    nonisolated func timelineBoundaries(in snapshot: WidgetSnapshot, at now: Date, calendar: Calendar) -> [Date] {
        WidgetDayPhase.boundaries(on: now, calendar: calendar)
    }
}
