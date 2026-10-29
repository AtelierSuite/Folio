import AppIntents
import Foundation

public struct DeleteReminderIntent: AppIntent {
    public static let title = LocalizedStringResource(
        "DeleteReminderIntent.Title", table: "AppIntents", bundle: #bundle
    )
    public static let description = IntentDescription(
        LocalizedStringResource("DeleteReminderIntent.Description", table: "AppIntents", bundle: #bundle)
    )

    @Parameter(title: LocalizedStringResource("DeleteReminderIntent.Reminder", table: "AppIntents", bundle: #bundle))
    public var reminder: ReminderEntity

    public static var parameterSummary: some ParameterSummary {
        Summary("Delete \(\.$reminder)", table: "AppIntents")
    }

    public init() {}

    public init(reminder: ReminderEntity) {
        self.reminder = reminder
    }

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let actions = ReminderIntentActions()
        let current = try await actions.reminder(for: reminder)
        guard !current.isReadOnly else { throw PlannerIntentError.readOnly }
        try await requestConfirmation(
            actionName: .delete,
            dialog: IntentDialog(stringLiteral: IntentDialogText.confirmReminderDeletion(current))
        )
        try await actions.deleteReminder(reminder)
        return .result(dialog: IntentDialog(stringLiteral: IntentDialogText.reminderDeleted(current)))
    }
}
