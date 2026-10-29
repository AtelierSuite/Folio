import Testing
@testable import Planner

struct PermissionKindTests {
    @Test func iPhoneSupportsEveryPermission() {
        let capabilities = PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: true)
        #expect(PermissionKind.allCases.allSatisfy { capabilities.supports(permission: $0) })
    }

    @Test func iPadHasNoHealth() {
        let capabilities = PlatformCapabilities(platform: .iPad, areLiveActivitiesSupported: false)
        let supported = PermissionKind.allCases.filter { capabilities.supports(permission: $0) }
        #expect(supported == [.calendar, .reminders, .notifications, .location, .alarms])
    }

    @Test func macHasCalendarRemindersNotificationsAndLocationForWeather() {
        let capabilities = PlatformCapabilities(platform: .mac, areLiveActivitiesSupported: false)
        let supported = PermissionKind.allCases.filter { capabilities.supports(permission: $0) }
        #expect(supported == [.calendar, .reminders, .notifications, .location])
    }
}
