import Foundation

extension NotificationContentFormatter {
    static var arrivedText: String {
        String(localized: "Notification.Arrived", table: "ArrivalAlerts", bundle: #bundle)
    }

    public func arrivalContent(for event: CalendarEvent, at date: Date) -> NotificationContent {
        let details = content(for: event, firingAt: date)
        return NotificationContent(
            title: event.title,
            body: [Self.arrivedText, details.body].filter { !$0.isEmpty }.joined(separator: Self.separator),
            status: Self.arrivedText,
            time: details.time,
            color: details.color,
            origin: details.origin
        )
    }
}
