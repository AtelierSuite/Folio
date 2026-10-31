import Foundation

extension NotificationContentFormatter {
    public func leaveContent(for alert: LeaveAlert) -> NotificationContent {
        let leave = alert.isLate
            ? String(localized: "Notification.LeaveNow", table: "LeaveAlerts", bundle: #bundle)
            : String(
                format: String(localized: "Notification.LeaveBy", table: "LeaveAlerts", bundle: #bundle),
                alert.leaveDate.formatted(Date.FormatStyle(
                    date: .omitted, time: .shortened, locale: locale, calendar: calendar, timeZone: calendar.timeZone
                ))
            )
        let travel = String(format: travelFormat(for: alert.transport), travelDuration(alert.travelTime))
        let details = content(for: alert.event, firingAt: alert.fireDate).body
        return NotificationContent(
            title: alert.event.title,
            body: [leave, travel, details].filter { !$0.isEmpty }.joined(separator: Self.separator)
        )
    }

    private func travelFormat(for transport: TravelTransport) -> String {
        switch transport {
        case .driving: String(localized: "Notification.Driving", table: "LeaveAlerts", bundle: #bundle)
        case .walking: String(localized: "Notification.Walking", table: "LeaveAlerts", bundle: #bundle)
        case .transit: String(localized: "Notification.Transit", table: "LeaveAlerts", bundle: #bundle)
        }
    }

    private func travelDuration(_ travelTime: TimeInterval) -> String {
        let minutes = max(1, Int((travelTime / 60).rounded()))
        var style = Duration.UnitsFormatStyle(allowedUnits: [.hours, .minutes], width: .abbreviated)
        style.locale = locale
        return Duration.seconds(minutes * 60).formatted(style)
    }
}
