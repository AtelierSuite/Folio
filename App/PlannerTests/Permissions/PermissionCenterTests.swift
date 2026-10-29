import Testing
@testable import Planner

@MainActor
struct PermissionCenterTests {
    private let iPhone = PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: true)
    private let mac = PlatformCapabilities(platform: .mac, areLiveActivitiesSupported: false)

    @Test func statusIsUnknownUntilRefreshed() async {
        let provider = FakePermissionProvider(status: .denied)
        let center = PermissionCenter(providers: [.notifications: provider], capabilities: iPhone)
        #expect(center.status(of: .notifications) == nil)
        await center.refresh()
        #expect(center.status(of: .notifications) == .denied)
    }

    @Test func permissionsWithoutProviderAreUnavailable() {
        let center = PermissionCenter(providers: [:], capabilities: iPhone)
        #expect(center.status(of: .health) == .unavailable)
        #expect(center.availableKinds.isEmpty)
    }

    @Test func unsupportedPermissionsAreUnavailable() async {
        let provider = FakePermissionProvider(status: .notDetermined)
        let center = PermissionCenter(providers: [.alarms: provider], capabilities: mac)
        #expect(center.status(of: .alarms) == .unavailable)
        #expect(await center.request(.alarms) == .unavailable)
        #expect(provider.requestCount == 0)
    }

    @Test func requestAsksProviderOnlyWhenRequestable() async {
        let provider = FakePermissionProvider(status: .notDetermined)
        let center = PermissionCenter(providers: [.notifications: provider], capabilities: iPhone)
        await center.refresh()
        #expect(await center.request(.notifications) == .granted)
        #expect(await center.request(.notifications) == .granted)
        #expect(provider.requestCount == 1)
    }

    @Test func requestDoesNotPromptWhenDenied() async {
        let provider = FakePermissionProvider(status: .denied)
        let center = PermissionCenter(providers: [.notifications: provider], capabilities: iPhone)
        await center.refresh()
        #expect(await center.request(.notifications) == .denied)
        #expect(provider.requestCount == 0)
    }

    @Test func failedRequestFallsBackToCurrentStatus() async {
        let provider = FakePermissionProvider(status: .notDetermined)
        provider.shouldThrow = true
        let center = PermissionCenter(providers: [.notifications: provider], capabilities: iPhone)
        #expect(await center.request(.notifications) == .notDetermined)
        #expect(center.status(of: .notifications) == .notDetermined)
    }

    @Test func calendarStatusesAreAvailableImmediatelyAndSeparately() async {
        let source = FakeCalendarDataSource()
        source.setAuthorization(.notDetermined, for: .event)
        source.setAuthorization(.denied, for: .reminder)
        let store = CalendarStore(source: source)
        let center = PermissionCenter(calendarStore: store, capabilities: iPhone)
        #expect(center.status(of: .calendar) == .notDetermined)
        #expect(center.status(of: .reminders) == .denied)

        #expect(await center.request(.calendar) == .granted)
        #expect(await center.request(.reminders) == .denied)
        #expect(source.requestedKinds == [.event])
        #expect(store.eventAuthorization == .fullAccess)
    }

    @Test func refreshPicksUpChangesMadeInSettings() async {
        let source = FakeCalendarDataSource()
        source.setAuthorization(.denied, for: .reminder)
        let store = CalendarStore(source: source)
        let center = PermissionCenter(calendarStore: store, capabilities: iPhone)
        let revision = store.contentRevision

        source.setAuthorization(.fullAccess, for: .reminder)
        await center.refresh(.reminders)

        #expect(center.status(of: .reminders) == .granted)
        #expect(store.reminderAuthorization == .fullAccess)
        #expect(store.contentRevision > revision)
    }
}
