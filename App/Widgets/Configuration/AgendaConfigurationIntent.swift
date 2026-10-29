import AppIntents
import Planner

struct AgendaConfigurationIntent: FolioWidgetIntent {
    static let title = LocalizedStringResource("Configuration.Agenda.Title", table: "Widgets")
    static let description = IntentDescription(LocalizedStringResource("Configuration.Agenda.Description", table: "Widgets"))

    @Parameter(title: LocalizedStringResource("Configuration.Calendars", table: "Widgets"))
    var calendars: [CalendarEntity]?

    @Parameter(title: LocalizedStringResource("Configuration.Lists", table: "Widgets"))
    var lists: [ReminderListEntity]?

    nonisolated init() {}

    nonisolated func snapshotRequest(at now: Date, calendar: Calendar) -> WidgetSnapshotRequest {
        .upcoming(
            from: now,
            calendar: calendar,
            calendars: calendars?.identifierSet,
            includesReminders: true,
            lists: lists?.identifierSet
        )
    }
}
