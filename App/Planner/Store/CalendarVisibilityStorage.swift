import Foundation

public struct CalendarVisibilityStorage: @unchecked Sendable {
    public static let hiddenCalendarIdentifiersKey = "Calendar.HiddenCalendarIdentifiers"
    public static let hidesDeclinedEventsKey = "Calendar.HidesDeclinedEvents"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var hiddenCalendarIdentifiers: Set<String> {
        get { Set(defaults.stringArray(forKey: Self.hiddenCalendarIdentifiersKey) ?? []) }
        nonmutating set { defaults.set(newValue.sorted(), forKey: Self.hiddenCalendarIdentifiersKey) }
    }

    public var hidesDeclinedEvents: Bool {
        get { defaults.bool(forKey: Self.hidesDeclinedEventsKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.hidesDeclinedEventsKey) }
    }
}
