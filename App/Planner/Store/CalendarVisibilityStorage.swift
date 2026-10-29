import Foundation

public struct CalendarVisibilityStorage: @unchecked Sendable {
    public static let hiddenCalendarIdentifiersKey = "Calendar.HiddenCalendarIdentifiers"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var hiddenCalendarIdentifiers: Set<String> {
        get { Set(defaults.stringArray(forKey: Self.hiddenCalendarIdentifiersKey) ?? []) }
        nonmutating set { defaults.set(newValue.sorted(), forKey: Self.hiddenCalendarIdentifiersKey) }
    }
}
