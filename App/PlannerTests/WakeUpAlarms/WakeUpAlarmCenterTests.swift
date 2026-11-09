import Foundation
import Testing
@testable import Planner

@MainActor
struct WakeUpAlarmCenterTests {
    private let now = Fixtures.date(2026, 10, 29, hour: 3)
    private let office = ArrivalFixtures.event("office", start: Fixtures.date(2026, 10, 29, hour: 9))
    private let farFromHome = PlannerCoordinate(latitude: 35.7, longitude: 139.7)
    private let standup = NotificationFixtures.event("standup", start: Fixtures.date(2026, 10, 29, hour: 9))

    private func makeCenter(
        events: [CalendarEvent],
        alarms: FakeAlarmClient = FakeAlarmClient(),
        platform: DevicePlatform = .iPhone,
        highlightsHolidays: Bool = false,
        locator: FakeLocator = FakeLocator(status: .granted, coordinate: LeaveFixtures.home),
        estimator: FakeTravelTimeEstimator = FakeTravelTimeEstimator(travelTime: 1800),
        monitor: FakeSignificantLocationMonitor = FakeSignificantLocationMonitor(),
        clock: @escaping @Sendable () -> Date = { Fixtures.date(2026, 10, 29, hour: 3) }
    ) throws -> WakeUpAlarmCenter {
        let defaults = try #require(UserDefaults(suiteName: "WakeUpAlarmCenterTests.\(UUID().uuidString)"))
        defaults.set(highlightsHolidays, forKey: DayHighlightSettings.highlightsHolidaysKey)
        defaults.set("JP", forKey: DayHighlightSettings.holidayRegionKey)
        return WakeUpAlarmCenter(
            capabilities: PlatformCapabilities(platform: platform, areLiveActivitiesSupported: false),
            source: FakeCalendarDataSource(events: events),
            settings: WakeUpAlarmSettings(defaults: defaults),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            alarmClient: alarms,
            ledger: AlarmLedger(key: "Wake", defaults: defaults),
            formatter: NotificationFixtures.formatter,
            loadHolidays: { _ in [Holiday(day: HolidayDay(year: 2026, month: 10, day: 29), name: "Holiday")] },
            clock: clock,
            locator: locator,
            resolver: EventCoordinateResolver(geocoder: FakeGeocoder(), cache: InMemoryGeocodeCache()),
            estimator: estimator,
            makeLocationMonitor: { monitor }
        )
    }

    @Test func enablingSchedulesASnoozableAlarmForTheFirstEvent() async throws {
        let alarms = FakeAlarmClient()
        let center = try makeCenter(events: [standup], alarms: alarms)
        await center.setEnabled(true)
        let scheduled = try #require(alarms.scheduledAlarms.first)
        #expect(alarms.scheduledCount == 1)
        #expect(scheduled.fireDate == Fixtures.date(2026, 10, 29).addingTimeInterval(7.5 * 3600))
        #expect(scheduled.title.contains("standup"))
        #expect(scheduled.title.contains("9:00"))
        #expect(scheduled.secondaryAction == .snooze(WakeUpAlarmPlanner.snoozeDuration))
        #expect(center.upcomingAlarms.map(\.event.title) == ["standup"])
    }

    @Test func changingTheLeadTimeReschedulesAndDisablingCancels() async throws {
        let alarms = FakeAlarmClient()
        let center = try makeCenter(events: [standup], alarms: alarms)
        await center.setEnabled(true)
        await center.setLeadMinutes(60)
        #expect(alarms.scheduledAlarms.map(\.fireDate) == [Fixtures.date(2026, 10, 29, hour: 8)])
        await center.setEnabled(false)
        #expect(alarms.scheduledCount == 0)
        #expect(center.upcomingAlarms.isEmpty)
    }

    @Test func leavesOtherFeaturesAlarmsAlone() async throws {
        let foreign = UUID()
        let alarms = FakeAlarmClient(foreignIdentifiers: [foreign])
        let center = try makeCenter(events: [standup], alarms: alarms)
        await center.setEnabled(true)
        await center.setEnabled(false)
        #expect(await alarms.scheduledIdentifiers() == [foreign])
    }

    @Test func deniedPermissionSchedulesNothing() async throws {
        let alarms = FakeAlarmClient(authorization: .denied)
        let center = try makeCenter(events: [standup], alarms: alarms)
        await center.setEnabled(true)
        #expect(alarms.scheduledCount == 0)
        #expect(center.authorization == .denied)
    }

    @Test func skipsHolidaysWhileHolidaysAreHighlighted() async throws {
        let alarms = FakeAlarmClient()
        let center = try makeCenter(events: [standup], alarms: alarms, highlightsHolidays: true)
        await center.setEnabled(true)
        await center.setSkipsHolidays(true)
        #expect(alarms.scheduledCount == 0)
        await center.setSkipsHolidays(false)
        #expect(alarms.scheduledCount == 1)
    }

    @Test func ringsOnHolidaysWhenHolidaysAreNotHighlighted() async throws {
        let alarms = FakeAlarmClient()
        let center = try makeCenter(events: [standup], alarms: alarms)
        await center.setEnabled(true)
        await center.setSkipsHolidays(true)
        #expect(alarms.scheduledCount == 1)
    }

    @Test func ignoresEventsFromExcludedCalendars() async throws {
        let alarms = FakeAlarmClient()
        let note = NotificationFixtures.event(
            "note", start: Fixtures.date(2026, 10, 29, hour: 7), calendarIdentifier: "notes"
        )
        let center = try makeCenter(events: [note, standup], alarms: alarms)
        await center.setEnabled(true)
        #expect(center.upcomingAlarms.map(\.event.title) == ["note"])
        await center.setIncludesCalendar(false, calendarIdentifier: "notes")
        #expect(!center.includesCalendar("notes"))
        #expect(center.upcomingAlarms.map(\.event.title) == ["standup"])
        #expect(alarms.scheduledCount == 1)
    }

    @Test func addsTravelTimeFromTheCurrentLocation() async throws {
        let alarms = FakeAlarmClient()
        let office = ArrivalFixtures.event("office", start: Fixtures.date(2026, 10, 29, hour: 9))
        let center = try makeCenter(events: [office], alarms: alarms)
        await center.setEnabled(true)
        #expect(alarms.scheduledAlarms.map(\.fireDate) == [Fixtures.date(2026, 10, 29).addingTimeInterval(7.5 * 3600)])
        await center.setAddsTravelTime(true)
        #expect(alarms.scheduledAlarms.map(\.fireDate) == [Fixtures.date(2026, 10, 29, hour: 7)])
        #expect(center.upcomingAlarms.first?.travelTime == 1800)
    }

    @Test func fallsBackToTheLastKnownOrigin() async throws {
        let alarms = FakeAlarmClient()
        let locator = FakeLocator(status: .denied)
        let office = ArrivalFixtures.event("office", start: Fixtures.date(2026, 10, 29, hour: 9))
        let center = try makeCenter(events: [office], alarms: alarms, locator: locator)
        center.settings.lastOrigin = LeaveFixtures.home
        await center.setEnabled(true)
        await center.setAddsTravelTime(true)
        #expect(alarms.scheduledAlarms.map(\.fireDate) == [Fixtures.date(2026, 10, 29, hour: 7)])
    }

    @Test func ignoresTravelTimeWithoutAnyKnownOrigin() async throws {
        let alarms = FakeAlarmClient()
        let office = ArrivalFixtures.event("office", start: Fixtures.date(2026, 10, 29, hour: 9))
        let center = try makeCenter(events: [office], alarms: alarms, locator: FakeLocator(status: .denied))
        await center.setEnabled(true)
        await center.setAddsTravelTime(true)
        #expect(alarms.scheduledAlarms.map(\.fireDate) == [Fixtures.date(2026, 10, 29).addingTimeInterval(7.5 * 3600)])
    }

    @Test func monitorsMovesOnlyWhileTravelTimeIsOnWithAlwaysAccess() async throws {
        let monitor = FakeSignificantLocationMonitor()
        let center = try makeCenter(events: [office], monitor: monitor)
        await center.setEnabled(true)
        #expect(!monitor.isMonitoring)
        await center.setAddsTravelTime(true)
        #expect(monitor.isMonitoring)
        #expect(monitor.authorizationRequestCount == 1)
        monitor.authorization = .whenInUse
        monitor.onAuthorizationChange?()
        #expect(!monitor.isMonitoring)
        monitor.authorization = .always
        monitor.onAuthorizationChange?()
        await center.setEnabled(false)
        #expect(!monitor.isMonitoring)
    }

    @Test func replansAfterMovingFarAtMostOnceAnHour() async throws {
        let alarms = FakeAlarmClient()
        let estimator = FakeTravelTimeEstimator(travelTime: 1800)
        let clock = WakeUpTestClock(now)
        let center = try makeCenter(events: [office], alarms: alarms, estimator: estimator, clock: { clock.now })
        await center.setEnabled(true)
        await center.setAddsTravelTime(true)
        estimator.setTravelTime(3600)
        clock.advance(by: 20 * 60)
        await center.locationDidChange(to: farFromHome)
        #expect(alarms.scheduledAlarms.map(\.fireDate) == [Fixtures.date(2026, 10, 29).addingTimeInterval(6.5 * 3600)])
        estimator.setTravelTime(600)
        clock.advance(by: 20 * 60)
        await center.locationDidChange(to: LeaveFixtures.home)
        #expect(alarms.scheduledAlarms.map(\.fireDate) == [Fixtures.date(2026, 10, 29).addingTimeInterval(6.5 * 3600)])
        clock.advance(by: 60 * 60)
        await center.locationDidChange(to: LeaveFixtures.home)
        let afterShorterTrip = Fixtures.date(2026, 10, 29).addingTimeInterval(7 * 3600 + 20 * 60)
        #expect(alarms.scheduledAlarms.map(\.fireDate) == [afterShorterTrip])
    }

    @Test func ignoresSmallMovesButRemembersThem() async throws {
        let alarms = FakeAlarmClient()
        let estimator = FakeTravelTimeEstimator(travelTime: 1800)
        let center = try makeCenter(events: [office], alarms: alarms, estimator: estimator)
        await center.setEnabled(true)
        await center.setAddsTravelTime(true)
        estimator.setTravelTime(3600)
        let nearby = PlannerCoordinate(latitude: 35.603, longitude: 139.7)
        await center.locationDidChange(to: nearby)
        #expect(alarms.scheduledAlarms.map(\.fireDate) == [Fixtures.date(2026, 10, 29, hour: 7)])
        #expect(center.settings.lastOrigin == nearby)
    }

    @Test func macDoesNotSupportWakeUpAlarms() async throws {
        let center = try makeCenter(events: [standup], platform: .mac)
        await center.setEnabled(true)
        #expect(!center.isSupported)
        #expect(!center.isEnabled)
    }
}
