import AppIntents
import Foundation

public struct CreateEventIntent: AppIntent {
    public static let title = LocalizedStringResource("CreateEventIntent.Title", table: "AppIntents", bundle: #bundle)
    public static let description = IntentDescription(
        LocalizedStringResource("CreateEventIntent.Description", table: "AppIntents", bundle: #bundle)
    )

    @Parameter(title: LocalizedStringResource("CreateEventIntent.EventTitle", table: "AppIntents", bundle: #bundle))
    public var eventTitle: String

    @Parameter(title: LocalizedStringResource("CreateEventIntent.StartDate", table: "AppIntents", bundle: #bundle))
    public var startDate: Date

    @Parameter(title: LocalizedStringResource("CreateEventIntent.EndDate", table: "AppIntents", bundle: #bundle))
    public var endDate: Date?

    @Parameter(
        title: LocalizedStringResource("CreateEventIntent.IsAllDay", table: "AppIntents", bundle: #bundle),
        default: false
    )
    public var isAllDay: Bool

    @Parameter(title: LocalizedStringResource("CreateEventIntent.Calendar", table: "AppIntents", bundle: #bundle))
    public var calendar: CalendarEntity?

    @Parameter(title: LocalizedStringResource("CreateEventIntent.Location", table: "AppIntents", bundle: #bundle))
    public var location: String?

    @Parameter(title: LocalizedStringResource("CreateEventIntent.Notes", table: "AppIntents", bundle: #bundle))
    public var notes: String?

    public static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$eventTitle) on \(\.$startDate)", table: "AppIntents") {
            \.$endDate
            \.$isAllDay
            \.$calendar
            \.$location
            \.$notes
        }
    }

    public init() {}

    @MainActor
    public func perform() async throws -> some ReturnsValue<EventEntity> & ProvidesDialog {
        let event = try await EventIntentActions().createEvent(NewEventRequest(
            title: eventTitle,
            startDate: startDate,
            endDate: endDate,
            isAllDay: isAllDay,
            calendarIdentifier: calendar?.id,
            location: location,
            notes: notes
        ))
        let dialog = IntentDialogText.eventCreated(event)
        return .result(value: EventEntity(event), dialog: IntentDialog(stringLiteral: dialog))
    }
}
