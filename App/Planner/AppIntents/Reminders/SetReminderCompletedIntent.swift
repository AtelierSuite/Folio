import AppIntents
import Foundation

/// Marks a reminder done, or not done again, for Siri and Shortcuts.
public struct SetReminderCompletedIntent: AppIntent {
    public static let title = LocalizedStringResource(
        "SetReminderCompletedIntent.Title", table: "AppIntents", bundle: #bundle
    )
    public static let description = IntentDescription(
        LocalizedStringResource("SetReminderCompletedIntent.Description", table: "AppIntents", bundle: #bundle)
    )

    @Parameter(
        title: LocalizedStringResource("SetReminderCompletedIntent.Reminder", table: "AppIntents", bundle: #bundle)
    )
    public var reminder: ReminderEntity

    @Parameter(
        title: LocalizedStringResource("SetReminderCompletedIntent.IsCompleted", table: "AppIntents", bundle: #bundle),
        default: true
    )
    public var isCompleted: Bool

    public static var parameterSummary: some ParameterSummary {
        When(\.$isCompleted, .equalTo, true) {
            Summary("Mark \(\.$reminder) as done", table: "AppIntents") {
                \.$isCompleted
            }
        } otherwise: {
            Summary("Mark \(\.$reminder) as not done", table: "AppIntents") {
                \.$isCompleted
            }
        }
    }

    public init() {}

    public init(reminder: ReminderEntity, isCompleted: Bool) {
        self.reminder = reminder
        self.isCompleted = isCompleted
    }

    @MainActor
    public func perform() async throws -> some ReturnsValue<ReminderEntity> & ProvidesDialog {
        let updated = try await ReminderIntentActions().setCompleted(isCompleted, for: reminder)
        var entity = ReminderEntity(updated)
        entity.isCompleted = isCompleted
        let dialog = IntentDialogText.reminderCompletion(updated, isCompleted: isCompleted)
        return .result(value: entity, dialog: IntentDialog(stringLiteral: dialog))
    }
}
