import Foundation
import Testing
@testable import Planner

@MainActor
struct WakeUpAlarmCenterTests {
    private let now = Fixtures.date(2026, 10, 29, hour: 3)
    private let standup = NotificationFixtures.event("standup", start: Fixtures.date(2026, 10, 29, hour: 9))

    private func makeCenter(
        events: [CalendarEvent],
        alarms: FakeAlarmClient = FakeAlarmClient(),
        platform: DevicePlatform = .iPhone,
        highlightsHolidays: Bool = false
    ) throws -> WakeUpAlarmCenter {
        let defaults = try #require(UserDefaults(suiteName: "WakeUpAlarmCenterTests.\(UUID().uuidString)"))
        defaults.set(highlightsHolidays, forKey: DayHighlightSettings.highlightsHolidaysKey)
        defaults.set("JP", forKey: DayHighlightSettings.holidayRegionKey)
        let now = now
        return WakeUpAlarmCenter(
            capabilities: PlatformCapabilities(platform: platform, areLiveActivitiesSupported: false),
            source: FakeCalendarDataSource(events: events),
            settings: WakeUpAlarmSettings(defaults: defaults),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            alarmClient: alarms,
            ledger: AlarmLedger(key: "Wake", defaults: defaults),
            formatter: NotificationFixtures.formatter,
            loadHolidays: { _ in [Holiday(day: HolidayDay(year: 2026, month: 10, day: 29), name: "Holiday")] },
            clock: { now }
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

    @Test func macDoesNotSupportWakeUpAlarms() async throws {
        let center = try makeCenter(events: [standup], platform: .mac)
        await center.setEnabled(true)
        #expect(!center.isSupported)
        #expect(!center.isEnabled)
    }
}
