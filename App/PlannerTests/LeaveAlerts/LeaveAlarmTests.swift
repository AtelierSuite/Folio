import Foundation
import Testing
@testable import Planner

@MainActor
struct LeaveAlarmTests {
    private struct Harness {
        let center: LeaveAlertCenter
        let scheduler: RecordingLeaveAlertScheduler
        let alarms: FakeAlarmClient
        let defaults: UserDefaults
    }

    private func makeHarness(
        events: [CalendarEvent],
        ringsAsAlarm: Bool = true,
        alarms: FakeAlarmClient = FakeAlarmClient(),
        estimator: FakeTravelTimeEstimator = FakeTravelTimeEstimator(travelTime: 1800),
        defaults sharedDefaults: UserDefaults? = nil
    ) throws -> Harness {
        let defaults = try sharedDefaults ?? #require(UserDefaults(suiteName: "LeaveAlarmTests.\(UUID().uuidString)"))
        let settings = LeaveAlertSettings(defaults: defaults)
        settings.isEnabled = true
        settings.ringsAsAlarm = ringsAsAlarm
        let notificationSettings = NotificationSettings(defaults: defaults)
        notificationSettings.isEnabled = true
        let scheduler = RecordingLeaveAlertScheduler()
        let center = LeaveAlertCenter(
            capabilities: PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: false),
            makeLocator: { FakeLeaveLocator(authorization: .always) },
            source: FakeCalendarDataSource(events: events),
            settings: settings,
            notificationSettings: notificationSettings,
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            preferences: InMemoryArrivalPreferences(enabled: Set(events.map(\.reference.storageKey))),
            resolver: EventCoordinateResolver(geocoder: FakeGeocoder(), cache: InMemoryGeocodeCache()),
            estimator: estimator,
            scheduler: scheduler,
            ledger: LeaveAlertLedger(defaults: defaults),
            travelTimes: LeaveTravelTimeCache(defaults: defaults),
            alarmClient: alarms,
            alarmLedger: AlarmLedger(key: "Leave", defaults: defaults),
            formatter: NotificationFixtures.formatter,
            clock: { ArrivalFixtures.now }
        )
        return Harness(center: center, scheduler: scheduler, alarms: alarms, defaults: defaults)
    }

    private let dentist = ArrivalFixtures.event("Dentist", start: ArrivalFixtures.hours(2))

    @Test func ringsUpcomingLeaveAlertsAsAlarmsWithAnOpenButton() async throws {
        let harness = try makeHarness(events: [dentist])
        await harness.center.replan()
        #expect(harness.scheduler.pendingAlerts.isEmpty)
        let alarm = try #require(harness.alarms.scheduledAlarms.first)
        #expect(alarm.fireDate == ArrivalFixtures.hours(1.5).addingTimeInterval(-300))
        #expect(alarm.secondaryAction == .open)
        #expect(alarm.title.hasPrefix("Dentist · "))
        #expect(alarm.item?.reference == dentist.reference)
    }

    @Test func lateAlertsStayNotifications() async throws {
        let harness = try makeHarness(events: [ArrivalFixtures.event("Soon", start: ArrivalFixtures.hours(0.4))])
        await harness.center.replan()
        #expect(harness.alarms.scheduledCount == 0)
        #expect(harness.scheduler.pendingAlerts.map(\.event.title) == ["Soon"])
    }

    @Test func turningTheAlarmOffCancelsItAndNotifiesInstead() async throws {
        let harness = try makeHarness(events: [dentist])
        await harness.center.replan()
        await harness.center.setRingsAsAlarm(false)
        #expect(harness.alarms.scheduledCount == 0)
        #expect(harness.scheduler.pendingAlerts.map(\.event.title) == ["Dentist"])
    }

    @Test func deniedOrRefusedAlarmsFallBackToNotifications() async throws {
        let denied = try makeHarness(events: [dentist], alarms: FakeAlarmClient(authorization: .denied))
        await denied.center.replan()
        #expect(denied.scheduler.pendingAlerts.count == 1)
        #expect(denied.center.alarmAuthorization == .denied)

        let full = FakeAlarmClient()
        full.setLimit(0)
        let refused = try makeHarness(events: [dentist], alarms: full)
        await refused.center.replan()
        #expect(refused.scheduler.pendingAlerts.count == 1)
    }

    @Test func keepsTheAlarmWhenTheLookupFailsAfterARelaunch() async throws {
        let first = try makeHarness(events: [dentist])
        await first.center.replan()
        let alarm = try #require(first.alarms.scheduledAlarms.first)
        let failing = FakeTravelTimeEstimator(travelTime: nil)
        failing.setFailing(true)
        let relaunched = try makeHarness(
            events: [dentist], alarms: first.alarms, estimator: failing, defaults: first.defaults
        )
        await relaunched.center.replan()
        #expect(relaunched.alarms.scheduledAlarms.map(\.id) == [alarm.id])
        #expect(relaunched.center.scheduledAlerts.map(\.travelTime) == [1800])
        #expect(relaunched.scheduler.pendingAlerts.isEmpty)
    }

    @Test func doesNotReuseTheTravelTimeForAMovedEvent() async throws {
        let first = try makeHarness(events: [dentist])
        await first.center.replan()
        let moved = ArrivalFixtures.event(
            "Dentist", start: ArrivalFixtures.hours(2), coordinate: ArrivalFixtures.coordinate(5)
        )
        #expect(moved.id == dentist.id)
        let failing = FakeTravelTimeEstimator(travelTime: nil)
        failing.setFailing(true)
        let relaunched = try makeHarness(
            events: [moved], alarms: first.alarms, estimator: failing, defaults: first.defaults
        )
        await relaunched.center.replan()
        #expect(relaunched.center.scheduledAlerts.isEmpty)
    }
}
