import Foundation
import Testing
@testable import Planner

@MainActor
struct ArrivalAlertCenterTests {
    private struct Harness {
        let center: ArrivalAlertCenter
        let monitor: FakeRegionMonitor?
        let notifier: RecordingArrivalNotifier
        let clock: TestClock
    }

    private final class TestClock: @unchecked Sendable {
        var now = ArrivalFixtures.now
    }

    private func makeHarness(
        events: [CalendarEvent],
        platform: DevicePlatform = .iPhone,
        isEnabled: Bool = true,
        authorization: ArrivalAuthorization = .always,
        enabledEvents: [CalendarEvent]? = nil
    ) throws -> Harness {
        let defaults = try #require(UserDefaults(suiteName: "ArrivalAlertCenterTests.\(UUID().uuidString)"))
        let settings = ArrivalAlertSettings(defaults: defaults)
        settings.isEnabled = isEnabled
        let notificationSettings = NotificationSettings(defaults: defaults)
        notificationSettings.isEnabled = true
        var monitor: FakeRegionMonitor?
        let notifier = RecordingArrivalNotifier()
        let clock = TestClock()
        let center = ArrivalAlertCenter(
            capabilities: PlatformCapabilities(platform: platform, areLiveActivitiesSupported: false),
            makeRegionMonitor: {
                let fake = FakeRegionMonitor(authorization: authorization)
                monitor = fake
                return fake
            },
            source: FakeCalendarDataSource(events: events),
            settings: settings,
            notificationSettings: notificationSettings,
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            preferences: InMemoryArrivalPreferences(
                enabled: Set((enabledEvents ?? events).map(\.reference.storageKey))
            ),
            resolver: EventCoordinateResolver(geocoder: FakeGeocoder(), cache: InMemoryGeocodeCache()),
            notifier: notifier,
            log: ArrivalNotificationLog(defaults: defaults),
            clock: { clock.now }
        )
        return Harness(center: center, monitor: monitor, notifier: notifier, clock: clock)
    }

    private func spreadEvents(_ count: Int) -> [CalendarEvent] {
        (0..<count).map { index in
            ArrivalFixtures.event(
                "Event \(index)", start: ArrivalFixtures.hours(Double(index) + 1),
                coordinate: ArrivalFixtures.coordinate(index)
            )
        }
    }

    @Test func monitorsAtMostTwentyRegionsAndRollsForward() async throws {
        let harness = try makeHarness(events: spreadEvents(30))
        let monitor = try #require(harness.monitor)
        await harness.center.replan()
        #expect(monitor.monitored.count == 20)
        harness.clock.now = ArrivalFixtures.hours(10)
        await harness.center.replan()
        #expect(monitor.monitored.count == 20)
        #expect(monitor.maximumMonitoredCount == 20)
        #expect(monitor.monitored.values.allSatisfy { $0.candidates.allSatisfy { $0.window.end > harness.clock.now } })
    }

    @Test func onlyMonitorsEventsWithArrivalAlertsTurnedOn() async throws {
        let events = spreadEvents(3)
        let harness = try makeHarness(events: events, enabledEvents: [events[1]])
        await harness.center.replan()
        #expect(harness.center.monitoredRegions.map { $0.candidates[0].event.title } == ["Event 1"])
    }

    @Test func turningOffRemovesEveryRegion() async throws {
        let harness = try makeHarness(events: spreadEvents(3))
        let monitor = try #require(harness.monitor)
        await harness.center.replan()
        #expect(monitor.monitored.count == 3)
        await harness.center.setEnabled(false)
        #expect(monitor.monitored.isEmpty)
    }

    @Test func turningOnAsksForLocationOnlyThen() async throws {
        let harness = try makeHarness(events: spreadEvents(2), isEnabled: false, authorization: .notDetermined)
        let monitor = try #require(harness.monitor)
        await harness.center.replan()
        #expect(monitor.authorizationRequestCount == 0)
        #expect(monitor.monitored.isEmpty)
        await harness.center.setEnabled(true)
        #expect(monitor.authorizationRequestCount == 1)
        monitor.grantAuthorization(.always)
        await harness.center.replan()
        #expect(monitor.monitored.count == 2)
    }

    @Test func iPadAndMacNeverCreateALocationMonitor() async throws {
        for platform in [DevicePlatform.iPad, .mac] {
            let harness = try makeHarness(events: spreadEvents(2), platform: platform, authorization: .notDetermined)
            #expect(harness.monitor == nil)
            #expect(!harness.center.isSupported)
            #expect(!harness.center.isEnabled)
            await harness.center.setEnabled(true)
            await harness.center.replan()
            #expect(harness.monitor == nil)
            #expect(harness.center.monitoredRegions.isEmpty)
        }
    }

    @Test func arrivalWithinTheWindowAlertsOnce() async throws {
        let meeting = ArrivalFixtures.event("Meeting", start: ArrivalFixtures.hours(1))
        let harness = try makeHarness(events: [meeting])
        await harness.center.replan()
        let identifier = ArrivalRegion.identifier(for: ArrivalFixtures.office)
        await harness.center.handle(RegionArrival(identifier: identifier, date: ArrivalFixtures.now))
        await harness.center.handle(RegionArrival(identifier: identifier, date: ArrivalFixtures.now))
        #expect(harness.notifier.notifiedTitles == ["Meeting"])
    }

    @Test func arrivalOutsideTheWindowStaysQuiet() async throws {
        let meeting = ArrivalFixtures.event("Meeting", start: ArrivalFixtures.hours(5))
        let harness = try makeHarness(events: [meeting])
        await harness.center.replan()
        await harness.center.handle(RegionArrival(
            identifier: ArrivalRegion.identifier(for: ArrivalFixtures.office), date: ArrivalFixtures.now
        ))
        #expect(harness.notifier.notifiedTitles.isEmpty)
        harness.clock.now = ArrivalFixtures.hours(3.5)
        await harness.center.handle(RegionArrival(
            identifier: ArrivalRegion.identifier(for: ArrivalFixtures.office), date: harness.clock.now
        ))
        #expect(harness.notifier.notifiedTitles == ["Meeting"])
    }

    @Test func arrivalAfterRelaunchReplansBeforeMatching() async throws {
        let meeting = ArrivalFixtures.event("Meeting", start: ArrivalFixtures.hours(1))
        let harness = try makeHarness(events: [meeting])
        #expect(harness.center.monitoredRegions.isEmpty)
        await harness.center.handle(RegionArrival(
            identifier: ArrivalRegion.identifier(for: ArrivalFixtures.office), date: ArrivalFixtures.now
        ))
        #expect(harness.notifier.notifiedTitles == ["Meeting"])
    }
}
