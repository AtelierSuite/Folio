import Testing
@testable import Planner

struct PlatformCapabilitiesTests {
    @Test func iPhoneSupportsEveryFeatureExceptCalendarControls() {
        let capabilities = PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: true)
        #expect(
            capabilities.supportedFeatures
                == Set(PlatformFeature.allCases).subtracting([.calendarPagingButtons, .timelineZoomMenu])
        )
    }

    @Test func iPadHidesSleepAndGeofencing() {
        let capabilities = PlatformCapabilities(platform: .iPad, areLiveActivitiesSupported: false)
        #expect(capabilities.supports(.alarms))
        #expect(capabilities.supports(.timeSensitiveNotifications))
        #expect(capabilities.supports(.weather))
        #expect(capabilities.supports(.invitationResponses))
        #expect(capabilities.supports(.calendarPagingButtons))
        #expect(capabilities.supports(.timelineZoomMenu))
        #expect(!capabilities.supports(.sleep))
        #expect(!capabilities.supports(.geofencedNotifications))
        #expect(!capabilities.supports(.leaveAlerts))
        #expect(!capabilities.supports(.liveActivityCountdown))
    }

    @Test func iPadShowsLiveActivitiesWhenSupported() {
        let capabilities = PlatformCapabilities(platform: .iPad, areLiveActivitiesSupported: true)
        #expect(capabilities.supports(.liveActivityCountdown))
    }

    @Test func macOnlySupportsNotificationsWeatherAndCalendarControls() {
        let capabilities = PlatformCapabilities(platform: .mac, areLiveActivitiesSupported: true)
        #expect(
            capabilities.supportedFeatures
                == [.timeSensitiveNotifications, .weather, .calendarPagingButtons, .timelineZoomMenu]
        )
    }
}
