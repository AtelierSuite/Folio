import Foundation
import Testing
@testable import Planner

struct AlternateCalendarSettingsTests {
    private func makeDefaults() -> UserDefaults {
        let suiteName = "AlternateCalendarSettingsTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    @Test func readsTheSelectedCalendar() {
        let defaults = makeDefaults()
        let settings = AlternateCalendarSettings(defaults: defaults)
        #expect(settings.selected == nil)
        defaults.set(AlternateCalendar.hebrew.rawValue, forKey: AlternateCalendar.storageKey)
        #expect(settings.selected == .hebrew)
        defaults.set("", forKey: AlternateCalendar.storageKey)
        #expect(settings.selected == nil)
    }
}
