import AppIntents
import Foundation

/// Asks before deleting; a recurring event loses just this occurrence.
public struct DeleteEventIntent: AppIntent {
    public static let title = LocalizedStringResource("DeleteEventIntent.Title", table: "AppIntents", bundle: #bundle)
    public static let description = IntentDescription(
        LocalizedStringResource("DeleteEventIntent.Description", table: "AppIntents", bundle: #bundle)
    )

    @Parameter(title: LocalizedStringResource("DeleteEventIntent.Event", table: "AppIntents", bundle: #bundle))
    public var event: EventEntity

    public static var parameterSummary: some ParameterSummary {
        Summary("Delete \(\.$event)", table: "AppIntents")
    }

    public init() {}

    public init(event: EventEntity) {
        self.event = event
    }

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let actions = EventIntentActions()
        let current = try await actions.event(for: event)
        guard !current.isReadOnly else { throw PlannerIntentError.readOnly }
        try await requestConfirmation(
            actionName: .delete,
            dialog: IntentDialog(stringLiteral: IntentDialogText.confirmEventDeletion(current))
        )
        try await actions.deleteEvent(event)
        return .result(dialog: IntentDialog(stringLiteral: IntentDialogText.eventDeleted(current)))
    }
}
