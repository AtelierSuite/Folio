import Foundation
import UserNotifications

/// Carries out what the user picked on a delivered alert, then re-plans the pending alerts.
@MainActor
public final class NotificationResponseHandler {
    let snoozes: any NotificationSnoozeClient
    let reminders: any ReminderCompleting
    let routing: any NotificationRouting
    let snoozePlanner: NotificationSnoozePlanner
    let replan: @MainActor () async -> Void
    let clock: @Sendable () -> Date

    public init(
        snoozes: any NotificationSnoozeClient = UserNotificationSnoozeClient(),
        reminders: any ReminderCompleting,
        routing: any NotificationRouting,
        snoozePlanner: NotificationSnoozePlanner = NotificationSnoozePlanner(),
        replan: @escaping @MainActor () async -> Void,
        clock: @escaping @Sendable () -> Date = { .now }
    ) {
        self.snoozes = snoozes
        self.reminders = reminders
        self.routing = routing
        self.snoozePlanner = snoozePlanner
        self.replan = replan
        self.clock = clock
    }

    public func handle(actionIdentifier: String, content: UNNotificationContent) async {
        let now = clock()
        let router = NotificationResponseRouter(now: now)
        guard let outcome = router.outcome(actionIdentifier: actionIdentifier, userInfo: content.userInfo) else {
            return
        }
        switch outcome {
        case .open(let route):
            routing.open(route)
        case .snooze(let snooze):
            await schedule(snooze, content: content, now: now)
        case .markDone(let item):
            try? await reminders.completeReminder(item.reference)
            await snoozes.removeSnoozes(withIdentifiers: [NotificationSnooze.identifier(for: item)])
        }
        await replan()
    }

    private func schedule(_ snooze: NotificationSnooze, content: UNNotificationContent, now: Date) async {
        let pending = await snoozes.pendingSnoozes()
        let overflow = snoozePlanner.identifiersToRemove(pending: pending, adding: snooze)
        await snoozes.removeSnoozes(withIdentifiers: overflow)
        try? await snoozes.schedule(snooze, content: content, now: now)
    }
}
