import Foundation
import Synchronization
import Testing
@testable import Planner

final class FakeReminderNotificationDismisser: ReminderNotificationDismissing {
    let storage = Mutex<[CalendarItemReference]>([])

    var dismissed: [CalendarItemReference] {
        storage.withLock { $0 }
    }

    func dismissNotifications(for reminder: CalendarItemReference) async {
        storage.withLock { $0.append(reminder) }
    }
}

@MainActor
struct ReminderNotificationDismissalTests {
    private let milk = Fixtures.reminder(local: "milk", due: Fixtures.date(2026, 10, 29, hour: 12))

    private func makeStore(dismisser: FakeReminderNotificationDismisser) throws -> CalendarStore {
        let defaults = try #require(UserDefaults(suiteName: "ReminderNotificationDismissal.\(UUID().uuidString)"))
        return CalendarStore(
            source: FakeCalendarDataSource(reminders: [milk]),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            reminderNotifications: dismisser
        )
    }

    private func userInfo(kind: CalendarItemKind, reference: CalendarItemReference) throws -> [AnyHashable: Any] {
        [
            NotificationUserInfo.kindKey: kind.rawValue,
            NotificationUserInfo.referenceKey: try JSONEncoder().encode(reference)
        ]
    }

    @Test func completingAReminderDismissesItsNotifications() async throws {
        let dismisser = FakeReminderNotificationDismisser()
        let store = try makeStore(dismisser: dismisser)
        try await store.setCompleted(true, for: milk)
        #expect(dismisser.dismissed == [milk.reference])
    }

    @Test func uncompletingAReminderKeepsItsNotifications() async throws {
        let dismisser = FakeReminderNotificationDismisser()
        let store = try makeStore(dismisser: dismisser)
        try await store.setCompleted(false, for: milk)
        #expect(dismisser.dismissed.isEmpty)
    }

    @Test func completingFromAnAlertDismissesItsNotifications() async throws {
        let dismisser = FakeReminderNotificationDismisser()
        let store = try makeStore(dismisser: dismisser)
        try await store.completeReminder(milk.reference)
        #expect(dismisser.dismissed == [milk.reference])
    }

    @Test func alertsMatchTheReminderByLocalOrExternalIdentifier() throws {
        let sameLocal = Fixtures.reference(external: nil, local: "milk")
        let sameExternal = Fixtures.reference(external: "external-milk", local: "moved")
        let other = Fixtures.reference(external: "external-bread", local: "bread")
        let reminder = milk.reference
        #expect(NotificationUserInfo.isAlert(try userInfo(kind: .reminder, reference: sameLocal), for: reminder))
        #expect(NotificationUserInfo.isAlert(try userInfo(kind: .reminder, reference: sameExternal), for: reminder))
        #expect(!NotificationUserInfo.isAlert(try userInfo(kind: .reminder, reference: other), for: reminder))
    }

    @Test func eventAlertsNeverMatchAReminder() throws {
        let reminder = milk.reference
        #expect(!NotificationUserInfo.isAlert(try userInfo(kind: .event, reference: reminder), for: reminder))
    }
}
