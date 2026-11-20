import Foundation

/// The alerts to schedule, plus the events whose travel time couldn't be estimated, so their pending alerts stay.
struct LeaveAlertPlan {
    var alerts: [LeaveAlert] = []
    var unestimatedEvents: [CalendarEvent] = []

    func keepsPendingAlert(withIdentifier identifier: String) -> Bool {
        unestimatedEvents.contains { identifier.hasPrefix(LeaveAlert.identifierPrefix(for: $0)) }
    }

    /// Keeps the soonest alerts within `LeaveAlert.notificationLimit`, counting the pending alerts this plan keeps.
    func cappedNotifications(_ alerts: [LeaveAlert], pendingIdentifiers: [String]) -> [LeaveAlert] {
        let keptCount = pendingIdentifiers.count(where: keepsPendingAlert(withIdentifier:))
        let sorted = alerts.sorted { ($0.fireDate, $0.id) < ($1.fireDate, $1.id) }
        return Array(sorted.prefix(max(0, LeaveAlert.notificationLimit - keptCount)))
    }
}

extension LeaveAlert {
    static func identifierPrefix(for event: CalendarEvent) -> String {
        "\(identifierPrefix)\(event.reference.storageKey)@"
    }
}
