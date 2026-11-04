import Foundation

public final class DuplicateDetectionSettings: @unchecked Sendable {
    public static let excludedCalendarsKey = "Duplicates.ExcludedCalendars"
    public static let shared = DuplicateDetectionSettings()

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var excludedCalendarIdentifiers: Set<String> {
        get { Set(defaults.stringArray(forKey: Self.excludedCalendarsKey) ?? []) }
        set { defaults.set(newValue.sorted(), forKey: Self.excludedCalendarsKey) }
    }
}
