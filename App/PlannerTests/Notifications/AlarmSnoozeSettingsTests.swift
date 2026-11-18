import Foundation
import Testing
@testable import Planner

struct AlarmSnoozeSettingsTests {
    private func makeSettings() throws -> AlarmSnoozeSettings {
        let suiteName = "AlarmSnoozeSettingsTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        return AlarmSnoozeSettings(defaults: defaults)
    }

    @Test func defaultsToNineMinutes() throws {
        let settings = try makeSettings()
        #expect(settings.minutes == 9)
        #expect(settings.duration == 9 * 60)
    }

    @Test func remembersTheChosenTime() throws {
        let settings = try makeSettings()
        settings.minutes = 25
        #expect(settings.minutes == 25)
        #expect(AlarmSecondaryAction.snooze(settings.duration) == .snooze(25 * 60))
    }

    @Test func keepsTheTimeBetweenOneAndThirtyMinutes() throws {
        let settings = try makeSettings()
        settings.minutes = 45
        #expect(settings.minutes == 30)
        settings.minutes = 0
        #expect(settings.minutes == 1)
    }
}
