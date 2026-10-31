import Foundation

/// Remembers when each event occurrence's leave alert is due, so one that already went off isn't sent again.
public struct LeaveAlertLedger: @unchecked Sendable {
    public static let storageKey = "LeaveAlerts.Scheduled"
    static let retention: TimeInterval = 2 * 86_400

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    private var entries: [String: TimeInterval] {
        get { defaults.dictionary(forKey: Self.storageKey) as? [String: TimeInterval] ?? [:] }
        nonmutating set { defaults.set(newValue, forKey: Self.storageKey) }
    }

    public func hasFired(for event: CalendarEvent, now: Date) -> Bool {
        entries[event.id].map { $0 <= now.timeIntervalSince1970 } ?? false
    }

    public func record(_ alerts: [LeaveAlert], now: Date) {
        let cutoff = now.addingTimeInterval(-Self.retention).timeIntervalSince1970
        var updated = entries.filter { $0.value >= cutoff }
        for alert in alerts {
            updated[alert.event.id] = alert.fireDate.timeIntervalSince1970
        }
        entries = updated
    }
}
