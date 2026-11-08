import AppIntents
import Planner

struct UpNextConfigurationIntent: FolioWidgetIntent {
    static let title = LocalizedStringResource("Configuration.Calendars.Title", table: "Widgets")
    static let description = IntentDescription(
        LocalizedStringResource("Configuration.Calendars.Description", table: "Widgets")
    )

    @Parameter(title: LocalizedStringResource("Configuration.Calendars", table: "Widgets"))
    var calendars: [CalendarEntity]?

    @Parameter(title: LocalizedStringResource("Configuration.ShowDetails", table: "Widgets"), default: true)
    var showsEventDetails: Bool

    static var parameterSummary: some ParameterSummary {
        #if os(iOS)
        When(widgetFamily: .oneOf, [.accessoryInline, .accessoryRectangular]) {
            Summary {
                \.$calendars
                \.$showsEventDetails
            }
        } otherwise: {
            Summary {
                \.$calendars
            }
        }
        #else
        Summary {
            \.$calendars
        }
        #endif
    }

    nonisolated init() {}

    nonisolated var showsDetails: Bool { showsEventDetails }

    nonisolated func snapshotRequest(at now: Date, calendar: Calendar) -> WidgetSnapshotRequest {
        .upcoming(from: now, calendar: calendar, calendars: calendars?.identifierSet)
    }
}
