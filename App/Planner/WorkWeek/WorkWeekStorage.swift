import Foundation

public struct WorkWeekStorage: @unchecked Sendable {
    public static let workdaysKey = "WorkWeek.Workdays"
    public static let excludedCalendarIdentifiersKey = "WorkWeek.ExcludedCalendarIdentifiers"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    /// `nil` until the user picks work days, so the locale default keeps following the system.
    public var workdays: Set<Int>? {
        get {
            guard let stored = defaults.array(forKey: Self.workdaysKey) as? [Int] else { return nil }
            let workdays = Set(stored).intersection(Calendar.weekdays)
            return workdays.isEmpty ? nil : workdays
        }
        nonmutating set {
            if let newValue {
                defaults.set(newValue.sorted(), forKey: Self.workdaysKey)
            } else {
                defaults.removeObject(forKey: Self.workdaysKey)
            }
        }
    }

    public var excludedCalendarIdentifiers: Set<String> {
        get { Set(defaults.stringArray(forKey: Self.excludedCalendarIdentifiersKey) ?? []) }
        nonmutating set { defaults.set(newValue.sorted(), forKey: Self.excludedCalendarIdentifiersKey) }
    }

    public func resolvedWorkdays(calendar: Calendar = .autoupdatingCurrent) -> Set<Int> {
        workdays ?? calendar.localeWorkdays
    }
}
