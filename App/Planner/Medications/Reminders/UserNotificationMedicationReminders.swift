import Foundation
import UserNotifications

public struct UserNotificationMedicationReminders: MedicationReminderScheduling {
    public init() {}

    public func pendingIdentifiers() async -> [String] {
        await UNUserNotificationCenter.current().pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(MedicationReminder.identifierPrefix) }
    }

    public func add(_ reminder: MedicationReminder) async throws {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body
        content.sound = .default
        content.threadIdentifier = "folio.medication"
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: reminder.date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        try await UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger)
        )
    }

    public func remove(identifiers: [String]) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
