import AppIntents

extension ConfirmationActionName {
    static var delete: ConfirmationActionName {
        .custom(
            acceptLabel: IntentStrings.resource("Confirmation.Delete"),
            acceptAlternatives: [],
            denyLabel: IntentStrings.resource("Confirmation.Cancel"),
            denyAlternatives: [],
            destructive: true
        )
    }
}
