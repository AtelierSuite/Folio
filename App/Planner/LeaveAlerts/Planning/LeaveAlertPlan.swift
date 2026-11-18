import Foundation

/// The alerts to schedule, plus the events whose travel time couldn't be estimated, so their pending alerts stay.
struct LeaveAlertPlan {
    var alerts: [LeaveAlert] = []
    var unestimatedEvents: [CalendarEvent] = []

    func keepsPendingAlert(withIdentifier identifier: String) -> Bool {
        unestimatedEvents.contains { identifier.hasPrefix(LeaveAlert.identifierPrefix(for: $0)) }
    }
}

extension LeaveAlert {
    static func identifierPrefix(for event: CalendarEvent) -> String {
        "\(identifierPrefix)\(event.reference.storageKey)@"
    }
}
