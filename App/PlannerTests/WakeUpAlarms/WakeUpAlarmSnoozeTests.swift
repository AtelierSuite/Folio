import Foundation
import Testing
@testable import Planner

@MainActor
struct WakeUpAlarmSnoozeTests {
    private struct Harness {
        let center: WakeUpAlarmCenter
        let alarms: FakeAlarmClient
        let source: FakeCalendarDataSource
        let clock: MovableClock

        /// Rings the wake-up alarm, snoozes it, then replans after it rang.
        func ringAndSnooze() async throws -> UUID {
            let rung = try #require(alarms.scheduledAlarms.first)
            clock.move(to: rung.fireDate.addingTimeInterval(120))
            alarms.snooze(rung.id)
            await center.replan()
            return rung.id
        }
    }

    private let standup = NotificationFixtures.event("standup", start: Fixtures.date(2026, 10, 29, hour: 9))

    private func makeHarness(
        events: [CalendarEvent]? = nil,
        estimator: FakeTravelTimeEstimator = FakeTravelTimeEstimator(travelTime: 1800),
        addsTravelTime: Bool = false
    ) async throws -> Harness {
        let defaults = try #require(UserDefaults(suiteName: "WakeUpAlarmSnoozeTests.\(UUID().uuidString)"))
        let alarms = FakeAlarmClient()
        let source = FakeCalendarDataSource(events: events ?? [standup])
        let clock = MovableClock(Fixtures.date(2026, 10, 29, hour: 3))
        let center = WakeUpAlarmCenter(
            capabilities: PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: false),
            source: source,
            settings: WakeUpAlarmSettings(defaults: defaults),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            alarmClient: alarms,
            ledger: AlarmLedger(key: "Wake", defaults: defaults),
            formatter: NotificationFixtures.formatter,
            loadHolidays: { _ in [] },
            clock: { clock.now },
            locator: FakeLocator(status: .granted, coordinate: LeaveFixtures.home),
            resolver: EventCoordinateResolver(geocoder: FakeGeocoder(), cache: InMemoryGeocodeCache()),
            estimator: estimator,
            makeLocationMonitor: { FakeSignificantLocationMonitor() }
        )
        await center.setEnabled(true)
        if addsTravelTime {
            await center.setAddsTravelTime(true)
        }
        return Harness(center: center, alarms: alarms, source: source, clock: clock)
    }

    @Test func aSnoozedAlarmWhoseEventStillExistsKeepsSnoozing() async throws {
        let harness = try await makeHarness()
        let snoozed = try await harness.ringAndSnooze()
        await harness.center.replan()
        #expect(harness.alarms.snoozingIdentifiers == [snoozed])
        #expect(harness.alarms.cancelCount == 0)
    }

    @Test func aSnoozedAlarmKeepsSnoozingWhenTheTravelTimeChanges() async throws {
        let office = ArrivalFixtures.event("office", start: Fixtures.date(2026, 10, 29, hour: 9))
        let estimator = FakeTravelTimeEstimator(travelTime: 1800)
        let harness = try await makeHarness(events: [office], estimator: estimator, addsTravelTime: true)
        let snoozed = try await harness.ringAndSnooze()
        estimator.setTravelTime(600)
        await harness.center.replan()
        #expect(harness.alarms.snoozingIdentifiers == [snoozed])
    }

    @Test func deletingTheEventCancelsTheSnoozedAlarm() async throws {
        let harness = try await makeHarness()
        _ = try await harness.ringAndSnooze()
        harness.source.replaceEvents([])
        await harness.center.replan()
        #expect(harness.alarms.snoozingIdentifiers.isEmpty)
    }

    @Test func turningOffWakeUpAlarmsCancelsTheSnoozedAlarm() async throws {
        let harness = try await makeHarness()
        _ = try await harness.ringAndSnooze()
        await harness.center.setEnabled(false)
        #expect(harness.alarms.snoozingIdentifiers.isEmpty)
    }
}
