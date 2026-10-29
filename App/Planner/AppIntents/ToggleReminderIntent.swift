import AppIntents
import Foundation

/// Marks a reminder done or not done, used by the interactive reminders widget.
public struct ToggleReminderIntent: AppIntent {
    public static let title = LocalizedStringResource("ToggleReminderIntent.Title", table: "Intents", bundle: #bundle)
    public static let isDiscoverable = false

    @Parameter(title: LocalizedStringResource("ToggleReminderIntent.Reminder", table: "Intents", bundle: #bundle))
    public var reminderIdentifier: String

    @Parameter(title: LocalizedStringResource("ToggleReminderIntent.IsCompleted", table: "Intents", bundle: #bundle))
    public var isCompleted: Bool

    public init() {}

    public init(reminderIdentifier: String, isCompleted: Bool) {
        self.reminderIdentifier = reminderIdentifier
        self.isCompleted = isCompleted
    }

    public func perform() async throws -> some IntentResult {
        try await EventKitDataSource.shared.setCompleted(isCompleted, reminderIdentifier: reminderIdentifier)
        return .result()
    }
}
