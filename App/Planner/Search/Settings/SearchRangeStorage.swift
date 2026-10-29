import Foundation

public struct SearchRangeStorage: @unchecked Sendable {
    public static let monthsBackKey = "Search.MonthsBack"
    public static let monthsAheadKey = "Search.MonthsAhead"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var range: SearchRange {
        get {
            SearchRange(
                monthsBack: defaults.object(forKey: Self.monthsBackKey) as? Int ?? SearchRange.default.monthsBack,
                monthsAhead: defaults.object(forKey: Self.monthsAheadKey) as? Int ?? SearchRange.default.monthsAhead
            )
        }
        nonmutating set {
            defaults.set(newValue.monthsBack, forKey: Self.monthsBackKey)
            defaults.set(newValue.monthsAhead, forKey: Self.monthsAheadKey)
        }
    }
}
