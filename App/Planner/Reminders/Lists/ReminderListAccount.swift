import Foundation

/// An account (EventKit source) that new reminder lists can be added to.
public struct ReminderListAccount: Identifiable, Sendable, Hashable {
    public let id: String
    public let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }

    /// Accounts already holding a writable list, in list order. Read-only and subscribed accounts are left out.
    public static func accounts(from lists: [PlannerCalendar]) -> [ReminderListAccount] {
        var accounts: [ReminderListAccount] = []
        for list in lists where !list.isReadOnly && !accounts.contains(where: { $0.id == list.sourceIdentifier }) {
            accounts.append(ReminderListAccount(id: list.sourceIdentifier, title: list.sourceTitle))
        }
        return accounts
    }
}
