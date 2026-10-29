import Foundation

public struct ReminderSettings: @unchecked Sendable {
    public static let overduePolicyKey = "Reminders.OverduePolicy"
    public static let defaultOverduePolicy = OverdueReminderPolicy.carryForward

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var overduePolicy: OverdueReminderPolicy {
        get {
            defaults.string(forKey: Self.overduePolicyKey).flatMap(OverdueReminderPolicy.init) ?? Self.defaultOverduePolicy
        }
        nonmutating set { defaults.set(newValue.rawValue, forKey: Self.overduePolicyKey) }
    }
}
