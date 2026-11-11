import Foundation

public struct FlexTimeStorage: @unchecked Sendable {
    public static let dayKindKeyPrefix = "FlexTime.DayKind."
    public static let delaysKey = "FlexTime.Delays"
    public static let excludedCalendarsKey = "FlexTime.ExcludedCalendars"
    public static let promptedDayKey = "FlexTime.PromptedDay"
    public static let firstOpenDayKey = "FlexTime.FirstOpenDay"
    public static let firstOpenTimeKey = "FlexTime.FirstOpenTime"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public func isEnabled(on kind: FlexTimeDayKind) -> Bool {
        defaults.object(forKey: Self.dayKindKeyPrefix + kind.rawValue) as? Bool ?? kind.isEnabledByDefault
    }

    public func setEnabled(_ isEnabled: Bool, on kind: FlexTimeDayKind) {
        defaults.set(isEnabled, forKey: Self.dayKindKeyPrefix + kind.rawValue)
    }

    public var enabledDayKinds: Set<FlexTimeDayKind> {
        Set(FlexTimeDayKind.allCases.filter(isEnabled(on:)))
    }

    public func schedule() -> FlexTimeSchedule {
        guard let stored = defaults.dictionary(forKey: Self.delaysKey) as? [String: Double], !stored.isEmpty else {
            return .none
        }
        var delays: [HolidayDay: TimeInterval] = [:]
        for (key, delay) in stored {
            guard let day = HolidayDay(storageKey: key) else { continue }
            delays[day] = delay
        }
        return FlexTimeSchedule(delays: delays, excludedCalendars: storedExcludedCalendars())
    }

    public func excludedCalendars(on day: HolidayDay) -> Set<String> {
        schedule().excludedCalendars[day] ?? []
    }

    public func delay(on day: HolidayDay) -> TimeInterval {
        schedule().delays[day] ?? 0
    }

    /// Days before `day` are dropped, as Flex Time only ever lasts for the day it was chosen on.
    public func setDelay(_ delay: TimeInterval, excluding excludedCalendars: Set<String> = [], on day: HolidayDay) {
        let schedule = schedule()
        var delays = schedule.delays.filter { $0.key > day }
        var excluded = schedule.excludedCalendars.filter { $0.key > day }
        if delay > 0 {
            delays[day] = delay
            excluded[day] = excludedCalendars
        }
        defaults.set(
            Dictionary(uniqueKeysWithValues: delays.map { ($0.key.storageKey, $0.value) }),
            forKey: Self.delaysKey
        )
        defaults.set(
            Dictionary(uniqueKeysWithValues: excluded.map { ($0.key.storageKey, $0.value.sorted()) }),
            forKey: Self.excludedCalendarsKey
        )
    }

    private func storedExcludedCalendars() -> [HolidayDay: Set<String>] {
        guard let stored = defaults.dictionary(forKey: Self.excludedCalendarsKey) as? [String: [String]] else {
            return [:]
        }
        var excluded: [HolidayDay: Set<String>] = [:]
        for (key, identifiers) in stored {
            guard let day = HolidayDay(storageKey: key) else { continue }
            excluded[day] = Set(identifiers)
        }
        return excluded
    }

    public var promptedDay: HolidayDay? {
        get { defaults.string(forKey: Self.promptedDayKey).flatMap(HolidayDay.init(storageKey:)) }
        nonmutating set { defaults.set(newValue?.storageKey, forKey: Self.promptedDayKey) }
    }

    public func firstOpen(on day: HolidayDay) -> Date? {
        guard defaults.string(forKey: Self.firstOpenDayKey) == day.storageKey else { return nil }
        return defaults.object(forKey: Self.firstOpenTimeKey) as? Date
    }

    public func recordOpen(at date: Date, on day: HolidayDay) {
        guard firstOpen(on: day) == nil else { return }
        defaults.set(day.storageKey, forKey: Self.firstOpenDayKey)
        defaults.set(date, forKey: Self.firstOpenTimeKey)
    }
}

extension HolidayDay {
    var storageKey: String {
        "\(year)-\(month)-\(day)"
    }

    init?(storageKey: String) {
        self.init(separatedDate: storageKey, separator: "-")
    }
}
