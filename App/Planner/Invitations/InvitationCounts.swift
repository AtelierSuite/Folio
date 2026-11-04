import Foundation

public struct InvitationCounts: Sendable, Equatable {
    public var pending: Int
    public var hiddenPending: Int

    public init(pending: Int = 0, hiddenPending: Int = 0) {
        self.pending = pending
        self.hiddenPending = hiddenPending
    }

    public var hasPendingInvitations: Bool {
        pending > 0 || hiddenPending > 0
    }
}
