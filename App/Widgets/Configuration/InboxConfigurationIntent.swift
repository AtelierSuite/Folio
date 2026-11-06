import AppIntents
import Planner

struct InboxConfigurationIntent: FolioWidgetIntent {
    static let title = LocalizedStringResource("Configuration.Agenda.Title", table: "Widgets")
    static let description = IntentDescription(LocalizedStringResource("Inbox.Description", table: "Widgets"))

    @Parameter(title: LocalizedStringResource("Configuration.Calendars", table: "Widgets"))
    var calendars: [CalendarEntity]?

    @Parameter(title: LocalizedStringResource("Configuration.Lists", table: "Widgets"))
    var lists: [ReminderListEntity]?

    @Parameter(title: LocalizedStringResource("Configuration.Medications", table: "Widgets"), default: true)
    var showsMedications: Bool

    nonisolated init() {}

    nonisolated func snapshotRequest(at now: Date, calendar: Calendar) -> WidgetSnapshotRequest {
        .inbox(
            from: now,
            calendar: calendar,
            calendars: calendars?.identifierSet,
            lists: lists?.identifierSet,
            includesMedications: showsMedications
        )
    }

    nonisolated func timelineBoundaries(in snapshot: WidgetSnapshot, at now: Date, calendar: Calendar) -> [Date] {
        snapshot.inboxBoundaries
    }
}
