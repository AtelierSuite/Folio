import Foundation
import Testing
@testable import Planner

@MainActor
struct WorkWeekPreferencesTests {
    private func makeStorage() throws -> WorkWeekStorage {
        let defaults = try #require(UserDefaults(suiteName: "WorkWeekPreferencesTests.\(UUID().uuidString)"))
        return WorkWeekStorage(defaults: defaults)
    }

    @Test func defaultsFollowTheLocaleUntilChanged() throws {
        let storage = try makeStorage()
        let preferences = WorkWeekPreferences(storage: storage, calendar: WorkdayDefaultsTests.calendar("he_IL"))
        #expect(preferences.workdays == [1, 2, 3, 4, 5])
        #expect(preferences.isUsingLocaleWorkdays)
        #expect(storage.workdays == nil)
    }

    @Test func changedWorkdaysArePersisted() throws {
        let storage = try makeStorage()
        let preferences = WorkWeekPreferences(storage: storage, calendar: WorkdayDefaultsTests.calendar("en_US"))
        preferences.setWorkday(false, for: 4)
        preferences.setWorkday(true, for: 7)
        #expect(preferences.workdays == [2, 3, 5, 6, 7])
        #expect(!preferences.isUsingLocaleWorkdays)
        let reloaded = WorkWeekPreferences(storage: storage, calendar: WorkdayDefaultsTests.calendar("he_IL"))
        #expect(reloaded.workdays == [2, 3, 5, 6, 7])
    }

    @Test func lastWorkdayCannotBeTurnedOff() throws {
        let storage = try makeStorage()
        storage.workdays = [3]
        let preferences = WorkWeekPreferences(storage: storage, calendar: WorkdayDefaultsTests.calendar("en_US"))
        preferences.setWorkday(false, for: 3)
        #expect(preferences.workdays == [3])
    }

    @Test func resettingReturnsToTheLocaleDefault() throws {
        let storage = try makeStorage()
        let preferences = WorkWeekPreferences(storage: storage, calendar: WorkdayDefaultsTests.calendar("en_US"))
        preferences.setWorkday(true, for: 1)
        preferences.useLocaleWorkdays()
        #expect(preferences.workdays == [2, 3, 4, 5, 6])
        #expect(preferences.isUsingLocaleWorkdays)
        #expect(storage.workdays == nil)
    }

    @Test func allCalendarsCountByDefaultAndExclusionsPersist() throws {
        let storage = try makeStorage()
        let preferences = WorkWeekPreferences(storage: storage, calendar: WorkdayDefaultsTests.calendar("en_US"))
        #expect(preferences.countsForWorkWeek(calendarIdentifier: "home"))
        preferences.setCountsForWorkWeek(false, calendarIdentifier: "home")
        #expect(!preferences.countsForWorkWeek(calendarIdentifier: "home"))
        #expect(storage.excludedCalendarIdentifiers == ["home"])
        preferences.setCountsForWorkWeek(true, calendarIdentifier: "home")
        #expect(storage.excludedCalendarIdentifiers.isEmpty)
    }
}
