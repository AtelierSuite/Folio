import Foundation
import Observation

@MainActor
@Observable
public final class WorkWeekPreferences {
    public private(set) var workdays: Set<Int>
    public private(set) var isUsingLocaleWorkdays: Bool
    public private(set) var excludedCalendarIdentifiers: Set<String>

    @ObservationIgnored private let storage: WorkWeekStorage
    @ObservationIgnored private let calendar: Calendar

    public init(storage: WorkWeekStorage = WorkWeekStorage(), calendar: Calendar = .autoupdatingCurrent) {
        self.storage = storage
        self.calendar = calendar
        workdays = storage.resolvedWorkdays(calendar: calendar)
        isUsingLocaleWorkdays = storage.workdays == nil
        excludedCalendarIdentifiers = storage.excludedCalendarIdentifiers
    }

    public func isWorkday(_ weekday: Int) -> Bool {
        workdays.contains(weekday)
    }

    /// Turning off the last work day is ignored so the working week never ends up empty.
    public func setWorkday(_ isWorkday: Bool, for weekday: Int) {
        guard Calendar.weekdays.contains(weekday) else { return }
        var updated = workdays
        if isWorkday {
            updated.insert(weekday)
        } else {
            updated.remove(weekday)
        }
        guard !updated.isEmpty, updated != workdays else { return }
        workdays = updated
        storage.workdays = updated
        isUsingLocaleWorkdays = false
    }

    public func useLocaleWorkdays() {
        storage.workdays = nil
        workdays = calendar.localeWorkdays
        isUsingLocaleWorkdays = true
    }

    public func countsForWorkWeek(calendarIdentifier: String) -> Bool {
        !excludedCalendarIdentifiers.contains(calendarIdentifier)
    }

    public func setCountsForWorkWeek(_ counts: Bool, calendarIdentifier: String) {
        if counts {
            excludedCalendarIdentifiers.remove(calendarIdentifier)
        } else {
            excludedCalendarIdentifiers.insert(calendarIdentifier)
        }
        storage.excludedCalendarIdentifiers = excludedCalendarIdentifiers
    }
}
