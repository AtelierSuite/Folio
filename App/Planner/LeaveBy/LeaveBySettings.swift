import Foundation

public struct LeaveBySettings: @unchecked Sendable {
    public static let isEnabledKey = "LeaveBy.Enabled"
    public static let statusKey = "LeaveBy.Status"
    public static let planKey = "LeaveBy.Plan"
    public static let handledArrivalsKey = "LeaveBy.HandledArrivals"
    static let retention: TimeInterval = 2 * 86_400

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var isEnabled: Bool {
        get { defaults.bool(forKey: Self.isEnabledKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.isEnabledKey) }
    }

    public var status: LeaveByStatus {
        get { defaults.string(forKey: Self.statusKey).flatMap(LeaveByStatus.init(rawValue:)) ?? .off }
        nonmutating set { defaults.set(newValue.rawValue, forKey: Self.statusKey) }
    }

    public var plan: LeaveByPlan? {
        get {
            defaults.data(forKey: Self.planKey).flatMap { try? JSONDecoder().decode(LeaveByPlan.self, from: $0) }
        }
        nonmutating set {
            defaults.set(newValue.flatMap { try? JSONEncoder().encode($0) }, forKey: Self.planKey)
        }
    }

    private var handledArrivals: [String: TimeInterval] {
        get { defaults.dictionary(forKey: Self.handledArrivalsKey) as? [String: TimeInterval] ?? [:] }
        nonmutating set { defaults.set(newValue, forKey: Self.handledArrivalsKey) }
    }

    public func hasHandledArrival(at event: CalendarEvent) -> Bool {
        handledArrivals[event.id] != nil
    }

    public func recordArrival(at event: CalendarEvent, on date: Date) {
        let cutoff = date.addingTimeInterval(-Self.retention).timeIntervalSince1970
        var updated = handledArrivals.filter { $0.value >= cutoff }
        updated[event.id] = date.timeIntervalSince1970
        handledArrivals = updated
    }
}
