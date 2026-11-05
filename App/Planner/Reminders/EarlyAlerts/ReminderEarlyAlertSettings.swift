import Foundation

public final class ReminderEarlyAlertSettings: Sendable {
    public static let storageKey = "Notifications.ReminderEarlyAlerts"
    public static let shared = ReminderEarlyAlertSettings()

    private let store: CalendarItemMetadataStore<[ReminderEarlyAlert]>

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        store = CalendarItemMetadataStore(key: Self.storageKey, defaults: defaults)
    }

    public func alerts(for reference: CalendarItemReference) -> [ReminderEarlyAlert] {
        store.value(for: reference.seriesReference) ?? []
    }

    public func setAlerts(_ alerts: [ReminderEarlyAlert], for reference: CalendarItemReference) {
        let unique = alerts.reduce(into: [ReminderEarlyAlert]()) { unique, alert in
            if !unique.contains(alert) {
                unique.append(alert)
            }
        }
        store.setValue(unique.isEmpty ? nil : unique, for: reference.seriesReference)
    }
}
