import Foundation
import Synchronization
import Testing
import UserNotifications
@testable import Planner

struct ReminderCompletionToggleTests {
    private let milk = Fixtures.reference(external: "external-milk", local: "milk")
    private let bread = Fixtures.reference(external: "external-bread", local: "bread")

    @Test func completingWritesAndDismissesTheReminderAlerts() async throws {
        let source = FakeCalendarDataSource()
        let dismisser = FakeReminderNotificationDismisser()
        try await ReminderCompletionToggle(source: source, notifications: dismisser)
            .setCompleted(true, reminderIdentifier: "milk")
        #expect(source.state.withLock { $0.completedReminderIdentifiers } == ["milk": true])
        #expect(dismisser.dismissed.map(\.localIdentifier) == ["milk"])
        #expect(dismisser.dismissed.allSatisfy { $0.identifiesSameItem(as: milk) })
    }

    @Test func uncompletingKeepsTheReminderAlerts() async throws {
        let source = FakeCalendarDataSource()
        let dismisser = FakeReminderNotificationDismisser()
        try await ReminderCompletionToggle(source: source, notifications: dismisser)
            .setCompleted(false, reminderIdentifier: "milk")
        #expect(source.state.withLock { $0.completedReminderIdentifiers } == ["milk": false])
        #expect(dismisser.dismissed.isEmpty)
    }

    @Test func snoozesAreAlwaysRemoved() throws {
        let requests = try pendingRequests()
        let identifiers = PendingReminderAlerts(includesScheduledAlerts: false).identifiers(in: requests, for: milk)
        #expect(identifiers == ["folio.snooze.reminder.milk"])
    }

    @Test func scheduledAlertsAreRemovedOnlyWhenAsked() throws {
        let requests = try pendingRequests()
        let identifiers = PendingReminderAlerts(includesScheduledAlerts: true).identifiers(in: requests, for: milk)
        #expect(identifiers == ["folio.snooze.reminder.milk", "folio.alert.reminder.milk@1"])
    }

    private func pendingRequests() throws -> [UNNotificationRequest] {
        [
            try request("folio.snooze.reminder.milk", kind: .reminder, reference: milk),
            try request("folio.alert.reminder.milk@1", kind: .reminder, reference: milk),
            try request("folio.alert.reminder.bread@1", kind: .reminder, reference: bread),
            try request("folio.alert.event.milk@1", kind: .event, reference: milk),
            try request("other.app.milk", kind: .reminder, reference: milk)
        ]
    }

    private func request(
        _ identifier: String, kind: CalendarItemKind, reference: CalendarItemReference
    ) throws -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.userInfo = [
            NotificationUserInfo.kindKey: kind.rawValue,
            NotificationUserInfo.referenceKey: try JSONEncoder().encode(reference)
        ]
        return UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
    }
}
