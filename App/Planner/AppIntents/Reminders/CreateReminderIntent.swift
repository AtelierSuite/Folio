import AppIntents
import Foundation

public struct CreateReminderIntent: AppIntent {
    public static let title = LocalizedStringResource(
        "CreateReminderIntent.Title", table: "AppIntents", bundle: #bundle
    )
    public static let description = IntentDescription(
        LocalizedStringResource("CreateReminderIntent.Description", table: "AppIntents", bundle: #bundle)
    )

    @Parameter(
        title: LocalizedStringResource("CreateReminderIntent.ReminderTitle", table: "AppIntents", bundle: #bundle)
    )
    public var reminderTitle: String

    @Parameter(title: LocalizedStringResource("CreateReminderIntent.DueDate", table: "AppIntents", bundle: #bundle))
    public var dueDate: Date?

    @Parameter(title: LocalizedStringResource("CreateReminderIntent.List", table: "AppIntents", bundle: #bundle))
    public var list: ReminderListEntity?

    @Parameter(title: LocalizedStringResource("CreateReminderIntent.Notes", table: "AppIntents", bundle: #bundle))
    public var notes: String?

    public static var parameterSummary: some ParameterSummary {
        Summary("Remind me to \(\.$reminderTitle)", table: "AppIntents") {
            \.$dueDate
            \.$list
            \.$notes
        }
    }

    public init() {}

    @MainActor
    public func perform() async throws -> some ReturnsValue<ReminderEntity> & ProvidesDialog {
        let reminder = try await ReminderIntentActions().createReminder(NewReminderRequest(
            title: reminderTitle, dueDate: dueDate, listIdentifier: list?.id, notes: notes
        ))
        let dialog = IntentDialogText.reminderCreated(reminder)
        return .result(value: ReminderEntity(reminder), dialog: IntentDialog(stringLiteral: dialog))
    }
}
