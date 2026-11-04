import Foundation

public struct InvitationCounts: Sendable, Equatable {
    public var pending: Int
    public var hidden: Int

    public init(pending: Int = 0, hidden: Int = 0) {
        self.pending = pending
        self.hidden = hidden
    }

    public var hasInvitations: Bool {
        pending > 0 || hidden > 0
    }
}
