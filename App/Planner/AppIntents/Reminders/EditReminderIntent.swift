import AppIntents
import Foundation

/// Changes only the fields that are filled in.
public struct EditReminderIntent: AppIntent {
    public static let title = LocalizedStringResource("EditReminderIntent.Title", table: "AppIntents", bundle: #bundle)
    public static let description = IntentDescription(
        LocalizedStringResource("EditReminderIntent.Description", table: "AppIntents", bundle: #bundle)
    )

    @Parameter(title: LocalizedStringResource("EditReminderIntent.Reminder", table: "AppIntents", bundle: #bundle))
    public var reminder: ReminderEntity

    @Parameter(title: LocalizedStringResource("EditReminderIntent.NewTitle", table: "AppIntents", bundle: #bundle))
    public var newTitle: String?

    @Parameter(title: LocalizedStringResource("EditReminderIntent.DueDate", table: "AppIntents", bundle: #bundle))
    public var dueDate: Date?

    @Parameter(title: LocalizedStringResource("EditReminderIntent.List", table: "AppIntents", bundle: #bundle))
    public var list: ReminderListEntity?

    @Parameter(title: LocalizedStringResource("EditReminderIntent.Notes", table: "AppIntents", bundle: #bundle))
    public var notes: String?

    public static var parameterSummary: some ParameterSummary {
        Summary("Edit \(\.$reminder)", table: "AppIntents") {
            \.$newTitle
            \.$dueDate
            \.$list
            \.$notes
        }
    }

    public init() {}

    public init(reminder: ReminderEntity) {
        self.reminder = reminder
    }

    @MainActor
    public func perform() async throws -> some ReturnsValue<ReminderEntity> & ProvidesDialog {
        let changes = ReminderChanges(title: newTitle, dueDate: dueDate, listIdentifier: list?.id, notes: notes)
        let edited = try await ReminderIntentActions().editReminder(reminder, with: changes)
        let dialog = IntentDialogText.reminderUpdated(edited)
        return .result(value: ReminderEntity(edited), dialog: IntentDialog(stringLiteral: dialog))
    }
}
