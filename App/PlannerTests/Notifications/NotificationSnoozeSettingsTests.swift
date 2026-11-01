import Foundation
import Testing
@testable import Planner

struct NotificationSnoozeSettingsTests {
    private func makeSettings() throws -> NotificationSnoozeSettings {
        let suiteName = "NotificationSnoozeSettingsTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        return NotificationSnoozeSettings(defaults: defaults)
    }

    @Test func defaultsToFiveAndFifteenMinutes() throws {
        #expect(try makeSettings().durations == NotificationSnoozeDurations(shortMinutes: 5, longMinutes: 15))
    }

    @Test func remembersTheChosenDurations() throws {
        let settings = try makeSettings()
        settings.durations = NotificationSnoozeDurations(shortMinutes: 30, longMinutes: 120)
        #expect(settings.durations.shortMinutes == 30)
        #expect(settings.durations.longMinutes == 120)
    }

    @Test func clampsDurationsToADay() {
        let durations = NotificationSnoozeDurations(shortMinutes: 0, longMinutes: 5000)
        #expect(durations.shortMinutes == 1)
        #expect(durations.longMinutes == 24 * 60)
    }
}
