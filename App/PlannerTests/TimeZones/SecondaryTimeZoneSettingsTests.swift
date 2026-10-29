import Foundation
import Testing
@testable import Planner

struct SecondaryTimeZoneSettingsTests {
    private func makeSettings() throws -> SecondaryTimeZoneSettings {
        let defaults = try #require(UserDefaults(suiteName: "SecondaryTimeZoneSettingsTests.\(UUID().uuidString)"))
        return SecondaryTimeZoneSettings(defaults: defaults)
    }

    @Test func offByDefault() throws {
        let settings = try makeSettings()
        #expect(!settings.isEnabled)
        #expect(settings.identifier.isEmpty)
        #expect(settings.shownTimeZone == nil)
    }

    @Test func shownOnlyWhenEnabledWithAZone() throws {
        let settings = try makeSettings()
        settings.identifier = "Asia/Tokyo"
        #expect(settings.shownTimeZone == nil)
        settings.isEnabled = true
        #expect(settings.shownTimeZone?.identifier == "Asia/Tokyo")
    }

    @Test func enabledWithoutAZoneShowsNothing() throws {
        let settings = try makeSettings()
        settings.isEnabled = true
        #expect(settings.shownTimeZone == nil)
    }

    @Test func unknownIdentifierShowsNothing() {
        #expect(SecondaryTimeZoneSettings.shownTimeZone(isEnabled: true, identifier: "Mars/Olympus_Mons") == nil)
    }
}
