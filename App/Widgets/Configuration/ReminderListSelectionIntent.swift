import AppIntents
import Planner

struct ReminderListSelectionIntent: FolioWidgetIntent {
    static let title = LocalizedStringResource("Configuration.Lists.Title", table: "Widgets")
    static let description = IntentDescription(LocalizedStringResource("Configuration.Lists.Description", table: "Widgets"))

    @Parameter(title: LocalizedStringResource("Configuration.Lists", table: "Widgets"))
    var lists: [ReminderListEntity]?

    nonisolated init() {}

    nonisolated func snapshotRequest(at now: Date, calendar: Calendar) -> WidgetSnapshotRequest {
        .reminders(lists: lists?.identifierSet)
    }
}
