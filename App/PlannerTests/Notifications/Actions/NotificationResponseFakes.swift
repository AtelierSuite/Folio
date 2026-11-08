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

final class FakeKeepClient: NotificationKeepClient {
    struct KeptAlert: @unchecked Sendable {
        let identifier: String
        let content: UNNotificationContent
    }

    let storage = Mutex<[KeptAlert]>([])

    var kept: [KeptAlert] {
        storage.withLock { $0 }
    }

    func keep(_ content: UNNotificationContent, identifier: String) async throws {
        storage.withLock { $0.append(KeptAlert(identifier: identifier, content: content)) }
    }
}

final class CapturingSnoozeClient: NotificationSnoozeClient {
    let storage = Mutex<[UNNotificationContentBox]>([])

    var scheduledContents: [UNNotificationContent] {
        storage.withLock { $0.map(\.content) }
    }

    func pendingSnoozes() async -> [NotificationSnooze] {
        []
    }

    func schedule(_ snooze: NotificationSnooze, content: UNNotificationContent, now: Date) async throws {
        storage.withLock { $0.append(UNNotificationContentBox(content: content)) }
    }

    func removeSnoozes(withIdentifiers identifiers: [String]) async {}
}

struct UNNotificationContentBox: @unchecked Sendable {
    let content: UNNotificationContent
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
