import Foundation

public struct ReminderListDraft: Sendable, Hashable {
    public var title: String
    public var color: PlannerColor
    public var accountIdentifier: String

    public init(title: String = "", color: PlannerColor = ReminderListPalette.colors[0], accountIdentifier: String) {
        self.title = title
        self.color = color
        self.accountIdentifier = accountIdentifier
    }

    public var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var isValid: Bool {
        !trimmedTitle.isEmpty && !accountIdentifier.isEmpty
    }
}
