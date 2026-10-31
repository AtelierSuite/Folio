import Foundation
import Testing
@testable import Planner

@MainActor
struct LeaveAlertCenterTests {
    private struct Harness {
        let center: LeaveAlertCenter
        let locator: FakeLeaveLocator?
        let estimator: FakeTravelTimeEstimator
        let scheduler: RecordingLeaveAlertScheduler
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
        travelTime: TimeInterval? = 1800,
        enabledEvents: [CalendarEvent]? = nil
    ) throws -> Harness {
        let defaults = try #require(UserDefaults(suiteName: "LeaveAlertCenterTests.\(UUID().uuidString)"))
        let settings = LeaveAlertSettings(defaults: defaults)
        settings.isEnabled = isEnabled
        let notificationSettings = NotificationSettings(defaults: defaults)
        notificationSettings.isEnabled = true
        var locator: FakeLeaveLocator?
        let estimator = FakeTravelTimeEstimator(travelTime: travelTime)
        let scheduler = RecordingLeaveAlertScheduler()
        let clock = TestClock()
        let center = LeaveAlertCenter(
            capabilities: PlatformCapabilities(platform: platform, areLiveActivitiesSupported: false),
            makeLocator: {
                let fake = FakeLeaveLocator(authorization: authorization)
                locator = fake
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
            estimator: estimator,
            scheduler: scheduler,
            ledger: LeaveAlertLedger(defaults: defaults),
            clock: { clock.now }
        )
        return Harness(center: center, locator: locator, estimator: estimator, scheduler: scheduler, clock: clock)
    }

    @Test func schedulesAlertsOnlyForEventsWithTheToggleOn() async throws {
        let events = [
            ArrivalFixtures.event("Dentist", start: ArrivalFixtures.hours(2)),
            ArrivalFixtures.event("Lunch", start: ArrivalFixtures.hours(3))
        ]
        let harness = try makeHarness(events: events, enabledEvents: [events[0]])
        await harness.center.replan()
        #expect(harness.scheduler.pendingAlerts.map(\.event.title) == ["Dentist"])
        #expect(harness.scheduler.pendingAlerts.first?.fireDate == ArrivalFixtures.hours(1.5).addingTimeInterval(-300))
    }

    @Test func reschedulesWhenTheTravelTimeChanges() async throws {
        let harness = try makeHarness(events: [ArrivalFixtures.event("Dentist", start: ArrivalFixtures.hours(2))])
        await harness.center.replan()
        harness.estimator.setTravelTime(2700)
        await harness.center.replan()
        #expect(harness.scheduler.pendingAlerts.count == 1)
        #expect(harness.scheduler.pendingAlerts.first?.leaveDate == ArrivalFixtures.hours(1.25))
    }

    @Test func doesNotSendAgainAfterTheAlertWentOff() async throws {
        let harness = try makeHarness(events: [ArrivalFixtures.event("Dentist", start: ArrivalFixtures.hours(2))])
        await harness.center.replan()
        harness.clock.now = ArrivalFixtures.hours(1.5)
        harness.scheduler.deliverDue(at: harness.clock.now)
        harness.estimator.setTravelTime(600)
        await harness.center.replan()
        #expect(harness.scheduler.pendingAlerts.isEmpty)
        #expect(harness.scheduler.scheduledAlerts.count == 1)
    }

    @Test func sendsALateAlertOnlyOnce() async throws {
        let harness = try makeHarness(events: [ArrivalFixtures.event("Dentist", start: ArrivalFixtures.hours(0.25))])
        await harness.center.replan()
        harness.scheduler.deliverDue(at: harness.clock.now)
        harness.clock.now = ArrivalFixtures.hours(0.1)
        await harness.center.replan()
        #expect(harness.scheduler.scheduledAlerts.count == 1)
        #expect(harness.scheduler.scheduledAlerts.first?.isLate == true)
    }

    @Test func removesPendingAlertsWhenTurnedOff() async throws {
        let harness = try makeHarness(events: [ArrivalFixtures.event("Dentist", start: ArrivalFixtures.hours(2))])
        await harness.center.replan()
        await harness.center.setEnabled(false)
        #expect(harness.scheduler.pendingAlerts.isEmpty)
        #expect(harness.center.scheduledAlerts.isEmpty)
    }

    @Test func keepsPendingAlertsWhenTheLocationIsUnknown() async throws {
        let harness = try makeHarness(events: [ArrivalFixtures.event("Dentist", start: ArrivalFixtures.hours(2))])
        await harness.center.replan()
        harness.locator?.coordinate = nil
        await harness.center.replan()
        #expect(harness.scheduler.pendingAlerts.count == 1)
    }

    @Test func requestsLocationAccessWhenTurnedOn() async throws {
        let harness = try makeHarness(events: [], isEnabled: false, authorization: .notDetermined)
        await harness.center.setEnabled(true)
        #expect(harness.locator?.authorizationRequestCount == 1)
    }

    @Test func staysOffWhereUnsupported() async throws {
        let harness = try makeHarness(
            events: [ArrivalFixtures.event("Dentist", start: ArrivalFixtures.hours(2))], platform: .iPad
        )
        await harness.center.replan()
        #expect(!harness.center.isSupported)
        #expect(harness.locator == nil)
        #expect(harness.scheduler.pendingAlerts.isEmpty)
    }
}
