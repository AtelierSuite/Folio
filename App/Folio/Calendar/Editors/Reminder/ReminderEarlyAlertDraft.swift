import Planner
import SwiftUI

struct ReminderEarlyAlertDraft {
    var alerts: [ReminderEarlyAlert]
    private let originalAlerts: [ReminderEarlyAlert]

    init(reference: CalendarItemReference?, settings: ReminderEarlyAlertSettings = .shared) {
        originalAlerts = reference.map(settings.alerts(for:)) ?? []
        alerts = originalAlerts
    }

    var hasChanges: Bool {
        alerts != originalAlerts
    }

    func save(for reference: CalendarItemReference, hasDueDate: Bool, in scheduler: NotificationScheduler) {
        let savedAlerts = hasDueDate ? alerts : []
        guard savedAlerts != originalAlerts else { return }
        Task { await scheduler.setEarlyAlerts(savedAlerts, for: reference) }
    }
}
