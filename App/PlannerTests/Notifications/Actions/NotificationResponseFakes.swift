import Foundation
import Synchronization
import UserNotifications
@testable import Planner

final class FakeSnoozeClient: NotificationSnoozeClient {
    let pending = Mutex<[NotificationSnooze]>([])

    var snoozes: [NotificationSnooze] {
        pending.withLock { $0 }
    }

    func pendingSnoozes() async -> [NotificationSnooze] {
        snoozes
    }

    func schedule(_ snooze: NotificationSnooze, content: UNNotificationContent, now: Date) async throws {
        pending.withLock { pending in
            pending.removeAll { $0.identifier == snooze.identifier }
            pending.append(snooze)
        }
    }

    func removeSnoozes(withIdentifiers identifiers: [String]) async {
        pending.withLock { $0.removeAll { identifiers.contains($0.identifier) } }
    }
}

@MainActor
final class FakeNotificationResponseTarget: NotificationRouting, ReminderCompleting {
    var routes: [NotificationRoute] = []
    var completed: [CalendarItemReference] = []
    var replanCount = 0

    func open(_ route: NotificationRoute) {
        routes.append(route)
    }

    func completeReminder(_ reference: CalendarItemReference) async throws {
        completed.append(reference)
    }
}
