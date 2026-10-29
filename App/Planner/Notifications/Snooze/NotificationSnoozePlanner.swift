import Foundation

/// Keeps snoozes within the pending slots the scheduler leaves free for them.
public struct NotificationSnoozePlanner: Sendable {
    public var limit: Int

    public init(limit: Int = NotificationPlanner.defaultReservedSlots) {
        self.limit = limit
    }

    /// The snoozes to cancel before adding `snooze`, dropping the ones due soonest when there are too many.
    public func identifiersToRemove(pending: [NotificationSnooze], adding snooze: NotificationSnooze) -> [String] {
        let others = pending
            .filter { $0.identifier != snooze.identifier }
            .sorted { ($0.fireDate, $0.identifier) < ($1.fireDate, $1.identifier) }
        let overflow = others.count + 1 - max(1, limit)
        return others.prefix(max(0, overflow)).map(\.identifier)
    }
}
