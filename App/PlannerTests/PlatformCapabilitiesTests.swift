import Testing
@testable import Planner

struct PlatformCapabilitiesTests {
    @Test func iPhoneSupportsEveryFeature() {
        let capabilities = PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: true)
        #expect(capabilities.supportedFeatures == Set(PlatformFeature.allCases))
    }

    @Test func iPadHidesSleepAndGeofencing() {
        let capabilities = PlatformCapabilities(platform: .iPad, areLiveActivitiesSupported: false)
        #expect(capabilities.supports(.alarms))
        #expect(capabilities.supports(.timeSensitiveNotifications))
        #expect(capabilities.supports(.weather))
        #expect(!capabilities.supports(.sleep))
        #expect(!capabilities.supports(.geofencedNotifications))
        #expect(!capabilities.supports(.liveActivityCountdown))
    }

    @Test func iPadShowsLiveActivitiesWhenSupported() {
        let capabilities = PlatformCapabilities(platform: .iPad, areLiveActivitiesSupported: true)
        #expect(capabilities.supports(.liveActivityCountdown))
    }

    @Test func macOnlySupportsNotificationsAndWeather() {
        let capabilities = PlatformCapabilities(platform: .mac, areLiveActivitiesSupported: true)
        #expect(capabilities.supportedFeatures == [.timeSensitiveNotifications, .weather])
    }
}
