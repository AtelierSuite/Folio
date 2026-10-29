import AppIntents
import Foundation

/// Changes only the fields that are filled in; a recurring event changes just this occurrence.
public struct EditEventIntent: AppIntent {
    public static let title = LocalizedStringResource("EditEventIntent.Title", table: "AppIntents", bundle: #bundle)
    public static let description = IntentDescription(
        LocalizedStringResource("EditEventIntent.Description", table: "AppIntents", bundle: #bundle)
    )

    @Parameter(title: LocalizedStringResource("EditEventIntent.Event", table: "AppIntents", bundle: #bundle))
    public var event: EventEntity

    @Parameter(title: LocalizedStringResource("EditEventIntent.NewTitle", table: "AppIntents", bundle: #bundle))
    public var newTitle: String?

    @Parameter(title: LocalizedStringResource("EditEventIntent.StartDate", table: "AppIntents", bundle: #bundle))
    public var startDate: Date?

    @Parameter(title: LocalizedStringResource("EditEventIntent.EndDate", table: "AppIntents", bundle: #bundle))
    public var endDate: Date?

    @Parameter(title: LocalizedStringResource("EditEventIntent.Calendar", table: "AppIntents", bundle: #bundle))
    public var calendar: CalendarEntity?

    @Parameter(title: LocalizedStringResource("EditEventIntent.Location", table: "AppIntents", bundle: #bundle))
    public var location: String?

    @Parameter(title: LocalizedStringResource("EditEventIntent.Notes", table: "AppIntents", bundle: #bundle))
    public var notes: String?

    public static var parameterSummary: some ParameterSummary {
        Summary("Edit \(\.$event)", table: "AppIntents") {
            \.$newTitle
            \.$startDate
            \.$endDate
            \.$calendar
            \.$location
            \.$notes
        }
    }

    public init() {}

    public init(event: EventEntity) {
        self.event = event
    }

    @MainActor
    public func perform() async throws -> some ReturnsValue<EventEntity> & ProvidesDialog {
        let changes = EventChanges(
            title: newTitle,
            startDate: startDate,
            endDate: endDate,
            calendarIdentifier: calendar?.id,
            location: location,
            notes: notes
        )
        let edited = try await EventIntentActions().editEvent(event, with: changes)
        let dialog = IntentDialogText.eventUpdated(edited)
        return .result(value: EventEntity(edited), dialog: IntentDialog(stringLiteral: dialog))
    }
}
