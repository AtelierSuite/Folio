import Testing
@testable import Planner

struct PermissionKindTests {
    @Test func iPhoneSupportsEveryPermission() {
        let capabilities = PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: true)
        #expect(PermissionKind.allCases.allSatisfy { capabilities.supports(permission: $0) })
    }

    @Test func iPadHasNoLocationOrHealth() {
        let capabilities = PlatformCapabilities(platform: .iPad, areLiveActivitiesSupported: false)
        #expect(PermissionKind.allCases.filter { capabilities.supports(permission: $0) } == [.calendar, .reminders, .notifications, .alarms])
    }

    @Test func macOnlyHasCalendarRemindersAndNotifications() {
        let capabilities = PlatformCapabilities(platform: .mac, areLiveActivitiesSupported: false)
        #expect(PermissionKind.allCases.filter { capabilities.supports(permission: $0) } == [.calendar, .reminders, .notifications])
    }
}
