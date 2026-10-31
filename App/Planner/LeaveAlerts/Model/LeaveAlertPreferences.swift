import Foundation

extension ArrivalAlertPreferences {
    public static let leaveAlertsStorageKey = "LeaveAlerts.Events"

    public static func leaveAlerts() -> ArrivalAlertPreferences {
        ArrivalAlertPreferences(store: CalendarItemMetadataStore(key: leaveAlertsStorageKey))
    }
}
