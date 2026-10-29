import Testing
import UserNotifications
@testable import Planner

struct PermissionStatusTests {
    @Test func onlyGrantedAndUnknownAllowAccess() {
        let allowing = Set([PermissionStatus.granted, .unknown])
        for status in [PermissionStatus.notDetermined, .limited, .granted, .denied, .restricted, .unknown, .unavailable] {
            #expect(status.allowsAccess == allowing.contains(status))
        }
    }

    @Test func undecidedAndLimitedStatusesCanBeRequested() {
        #expect(PermissionStatus.notDetermined.canRequest)
        #expect(PermissionStatus.limited.canRequest)
        #expect(!PermissionStatus.denied.canRequest)
        #expect(!PermissionStatus.granted.canRequest)
        #expect(!PermissionStatus.unknown.canRequest)
    }

    @Test func onlyDeniedPointsToSettings() {
        #expect(PermissionStatus.denied.canBeFixedInSettings)
        #expect(!PermissionStatus.restricted.canBeFixedInSettings)
        #expect(!PermissionStatus.notDetermined.canBeFixedInSettings)
    }

    @Test func unknownMayHideMissingAccess() {
        #expect(PermissionStatus.unknown.mayHideMissingAccess)
        #expect(!PermissionStatus.granted.mayHideMissingAccess)
    }

    @Test func mapsCalendarAuthorization() {
        #expect(PermissionStatus(CalendarAuthorizationStatus.notDetermined) == .notDetermined)
        #expect(PermissionStatus(CalendarAuthorizationStatus.restricted) == .restricted)
        #expect(PermissionStatus(CalendarAuthorizationStatus.denied) == .denied)
        #expect(PermissionStatus(CalendarAuthorizationStatus.writeOnly) == .limited)
        #expect(PermissionStatus(CalendarAuthorizationStatus.fullAccess) == .granted)
    }

    @Test func mapsNotificationAuthorization() {
        #expect(PermissionStatus(UNAuthorizationStatus.notDetermined) == .notDetermined)
        #expect(PermissionStatus(UNAuthorizationStatus.denied) == .denied)
        #expect(PermissionStatus(UNAuthorizationStatus.authorized) == .granted)
        #expect(PermissionStatus(UNAuthorizationStatus.provisional) == .granted)
    }
}
