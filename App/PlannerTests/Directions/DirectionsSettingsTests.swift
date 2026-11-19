import Foundation
import Testing
@testable import Planner

struct DirectionsSettingsTests {
    private func settings() -> DirectionsSettings {
        let suite = "DirectionsSettingsTests.\(UUID().uuidString)"
        return DirectionsSettings(defaults: UserDefaults(suiteName: suite) ?? .standard)
    }

    @Test func defaultsToAppleMaps() {
        #expect(settings().app == .appleMaps)
    }

    @Test func unknownAppsFallBackToAppleMaps() {
        let suite = "DirectionsSettingsTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite) ?? .standard
        defaults.set("removedApp", forKey: DirectionsSettings.appKey)
        #expect(DirectionsSettings(defaults: defaults).app == .appleMaps)
    }

    @Test func usesTheChosenAppOnlyWhileItIsInstalled() throws {
        let settings = settings()
        settings.app = .naverMap
        let request = try DirectionsFixtures.request(coordinate: DirectionsFixtures.gangnamStation)
        #expect(settings.url(for: request)?.host() == "maps.apple.com")
        settings.appIsInstalled = true
        #expect(settings.url(for: request)?.scheme == "nmap")
    }
}
