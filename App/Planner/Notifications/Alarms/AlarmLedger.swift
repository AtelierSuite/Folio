import Foundation

/// The alarms one feature scheduled, so it only cancels its own and leaves the others' alone.
public struct AlarmLedger: @unchecked Sendable {
    public static let key = "Notifications.ScheduledAlarms"

    private let defaults: UserDefaults
    private let key: String

    public init(key: String = Self.key, defaults: UserDefaults = AppGroup.userDefaults) {
        self.key = key
        self.defaults = defaults
    }

    public var identifiers: Set<UUID> {
        get { Set((defaults.stringArray(forKey: key) ?? []).compactMap(UUID.init(uuidString:))) }
        nonmutating set { defaults.set(newValue.map(\.uuidString).sorted(), forKey: key) }
    }

    /// What each owned alarm rings for, keyed by alarm, to tell once it has rung whether that still exists.
    public var sources: [UUID: String] {
        get {
            let stored = defaults.dictionary(forKey: sourcesKey) as? [String: String] ?? [:]
            return Dictionary(uniqueKeysWithValues: stored.compactMap { key, source in
                UUID(uuidString: key).map { ($0, source) }
            })
        }
        nonmutating set {
            let stored = Dictionary(uniqueKeysWithValues: newValue.map { ($0.key.uuidString, $0.value) })
            defaults.set(stored, forKey: sourcesKey)
        }
    }

    private var sourcesKey: String {
        "\(key).Sources"
    }
}
