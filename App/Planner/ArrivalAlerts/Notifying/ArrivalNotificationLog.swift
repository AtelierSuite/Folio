import Foundation

/// Remembers which event occurrences already had an arrival alert, so re-entering a region stays quiet.
public struct ArrivalNotificationLog: @unchecked Sendable {
    public static let storageKey = "ArrivalAlerts.Notified"
    static let retention: TimeInterval = 2 * 86_400

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    private var entries: [String: TimeInterval] {
        get { defaults.dictionary(forKey: Self.storageKey) as? [String: TimeInterval] ?? [:] }
        nonmutating set { defaults.set(newValue, forKey: Self.storageKey) }
    }

    public func hasNotified(_ candidate: ArrivalCandidate) -> Bool {
        entries[candidate.event.id] != nil
    }

    public func record(_ candidate: ArrivalCandidate, at date: Date) {
        let cutoff = date.addingTimeInterval(-Self.retention).timeIntervalSince1970
        var updated = entries.filter { $0.value >= cutoff }
        updated[candidate.event.id] = date.timeIntervalSince1970
        entries = updated
    }
}
