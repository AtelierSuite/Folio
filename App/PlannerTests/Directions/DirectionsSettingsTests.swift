import Foundation
import Testing
@testable import Planner

struct DirectionsSettingsTests {
    private func settings() -> DirectionsSettings {
        let suite = "DirectionsSettingsTests.\(UUID().uuidString)"
        return DirectionsSettings(defaults: UserDefaults(suiteName: suite) ?? .standard)
    }

    @Test func defaultsToAppleMaps() {
        let settings = settings()
        #expect(settings.mapsApp == .appleMaps)
        #expect(settings.navigationApp == .appleMaps)
    }

    @Test func unknownAppsFallBackToAppleMaps() {
        let suite = "DirectionsSettingsTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite) ?? .standard
        defaults.set("removedApp", forKey: DirectionsSettings.navigationAppKey)
        #expect(DirectionsSettings(defaults: defaults).navigationApp == .appleMaps)
    }

    @Test func navigationOnlyAppsAreNotUsedAsTheMapsApp() {
        let settings = settings()
        settings.setApp(.yahooCarNavi, for: .maps)
        #expect(settings.mapsApp == .appleMaps)
    }

    @Test func usesTheChosenAppOnlyWhileItIsInstalled() throws {
        let settings = settings()
        settings.setApp(.naverMap, for: .navigation)
        let request = try DirectionsFixtures.request(coordinate: DirectionsFixtures.gangnamStation)
        #expect(settings.url(for: request)?.host() == "maps.apple.com")
        settings.setAppIsInstalled(true, for: .navigation)
        #expect(settings.url(for: request)?.scheme == "nmap")
    }

    @Test func directionsFallBackToTheMapsAppOutsideTheNavigationAppsCountry() throws {
        let settings = settings()
        settings.setApp(.kakaoMap, for: .navigation)
        settings.setAppIsInstalled(true, for: .navigation)
        settings.setApp(.googleMaps, for: .maps)
        settings.setAppIsInstalled(true, for: .maps)
        let tokyo = try DirectionsFixtures.request(coordinate: DirectionsFixtures.tokyoStation)
        #expect(settings.url(for: tokyo)?.scheme == "comgooglemaps")
        let gangnam = try DirectionsFixtures.request(coordinate: DirectionsFixtures.gangnamStation)
        #expect(settings.url(for: gangnam)?.scheme == "kakaomap")
    }

    @Test func placesOpenInTheMapsApp() throws {
        let settings = settings()
        settings.setApp(.yahooCarNavi, for: .navigation)
        settings.setApp(.googleMaps, for: .maps)
        settings.setAppIsInstalled(true, for: .maps)
        let place = try #require(
            DirectionsDestination(name: "Tokyo Station", coordinate: DirectionsFixtures.tokyoStation)
        )
        #expect(settings.placeURL(for: place)?.scheme == "comgooglemaps")
    }
}
