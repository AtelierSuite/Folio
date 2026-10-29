import Foundation

extension NotificationContentFormatter {
    static var arrivedText: String {
        String(localized: "Notification.Arrived", table: "ArrivalAlerts", bundle: #bundle)
    }

    public func arrivalContent(for event: CalendarEvent, at date: Date) -> NotificationContent {
        let details = content(for: event, firingAt: date).body
        return NotificationContent(
            title: event.title,
            body: [Self.arrivedText, details].filter { !$0.isEmpty }.joined(separator: Self.separator)
        )
    }
}
