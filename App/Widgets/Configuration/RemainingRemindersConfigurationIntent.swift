import AppIntents
import Planner

#if os(iOS)
struct RemainingRemindersConfigurationIntent: FolioWidgetIntent {
    static let title = LocalizedStringResource("Configuration.Lists.Title", table: "Widgets")
    static let description = IntentDescription(
        LocalizedStringResource("Configuration.Lists.Description", table: "Widgets")
    )

    @Parameter(title: LocalizedStringResource("Configuration.Lists", table: "Widgets"))
    var lists: [ReminderListEntity]?

    @Parameter(title: LocalizedStringResource("Configuration.ShowDetails", table: "Widgets"), default: true)
    var showsReminderDetails: Bool

    static var parameterSummary: some ParameterSummary {
        When(widgetFamily: .equalTo, .accessoryRectangular) {
            Summary {
                \.$lists
                \.$showsReminderDetails
            }
        } otherwise: {
            Summary {
                \.$lists
            }
        }
    }

    nonisolated init() {}

    nonisolated var showsDetails: Bool { showsReminderDetails }

    nonisolated func snapshotRequest(at now: Date, calendar: Calendar) -> WidgetSnapshotRequest {
        .reminders(lists: lists?.identifierSet)
    }
}
#endif
