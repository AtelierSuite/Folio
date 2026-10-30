import Foundation
import Testing
@testable import Planner

@MainActor
struct NotificationSchedulerStyleTests {
    private struct Harness {
        let scheduler: NotificationScheduler
        let center: FakeNotificationCenter
        let alarms: FakeAlarmClient
        let source: FakeCalendarDataSource
    }

    private func makeHarness(
        events: [CalendarEvent],
        platform: DevicePlatform = .iPhone,
        alarmAuthorization: NotificationAuthorization = .authorized,
        foreignAlarms: [UUID] = []
    ) throws -> Harness {
        let defaults = try #require(UserDefaults(suiteName: "NotificationSchedulerStyleTests.\(UUID().uuidString)"))
        let settings = NotificationSettings(defaults: defaults)
        settings.isEnabled = true
        let center = FakeNotificationCenter()
        let alarms = FakeAlarmClient(authorization: alarmAuthorization, foreignIdentifiers: foreignAlarms)
        let source = FakeCalendarDataSource(events: events)
        let scheduler = NotificationScheduler(
            source: source,
            center: center,
            alarmClient: alarms,
            alarmLedger: AlarmLedger(defaults: defaults),
            settings: settings,
            styleSettings: NotificationStyleSettings(defaults: defaults),
            allDayAlertTimeSettings: AllDayAlertTimeSettings(defaults: defaults),
            capabilities: PlatformCapabilities(platform: platform, areLiveActivitiesSupported: false),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            clock: { NotificationFixtures.now }
        )
        return Harness(scheduler: scheduler, center: center, alarms: alarms, source: source)
    }

    private let work = NotificationFixtures.event("work", start: NotificationFixtures.hours(1))
    private let wake = NotificationFixtures.event(
        "wake", start: NotificationFixtures.hours(2), calendarIdentifier: "wake"
    )

    @Test func calendarDefaultsAndItemOverridesReachTheCenter() async throws {
        let harness = try makeHarness(events: [work, wake])
        await harness.scheduler.setDefaultStyle(.timeSensitive, forCalendar: "wake")
        #expect(harness.center.pendingNotifications.map(\.style) == [.standard, .timeSensitive])

        await harness.scheduler.setStyleOverride(.timeSensitive, for: work.reference)
        #expect(harness.center.pendingNotifications.map(\.style) == [.timeSensitive, .timeSensitive])
        #expect(harness.scheduler.styleOverride(for: work.reference) == .timeSensitive)
    }

    @Test func alarmStyleItemsAreScheduledWithAlarmsInsteadOfNotifications() async throws {
        let foreign = UUID()
        let harness = try makeHarness(events: [work, wake], foreignAlarms: [foreign])
        await harness.scheduler.setDefaultStyle(.alarm, forCalendar: "wake")
        #expect(harness.center.pendingNotifications.map(\.content.title) == ["work"])
        #expect(harness.alarms.scheduledAlarms.map(\.content.title) == ["wake"])
        #expect(harness.scheduler.lastReport?.alarmCount == 1)
        #expect(harness.scheduler.lastReport?.nextFireDate == work.startDate.addingTimeInterval(-600))

        await harness.scheduler.replan()
        #expect(harness.alarms.scheduleCount == 1)

        await harness.scheduler.setDefaultStyle(.standard, forCalendar: "wake")
        #expect(harness.alarms.scheduledAlarms.isEmpty)
        #expect(harness.alarms.scheduledCount == 1)
        #expect(harness.center.pendingNotifications.map(\.content.title) == ["work", "wake"])
    }

    @Test func disablingNotificationsCancelsAlarms() async throws {
        let harness = try makeHarness(events: [wake])
        await harness.scheduler.setDefaultStyle(.alarm, forCalendar: "wake")
        #expect(harness.alarms.scheduledCount == 1)
        await harness.scheduler.setEnabled(false)
        #expect(harness.alarms.scheduledCount == 0)
    }

    @Test func deniedAlarmPermissionFallsBackToTimeSensitive() async throws {
        let harness = try makeHarness(events: [wake], alarmAuthorization: .denied)
        await harness.scheduler.setStyleOverride(.alarm, for: wake.reference)
        #expect(harness.alarms.scheduledCount == 0)
        #expect(harness.center.pendingNotifications.map(\.style) == [.timeSensitive])

        harness.alarms.setAuthorization(.authorized)
        await harness.scheduler.replan()
        #expect(harness.center.pendingCount == 0)
        #expect(harness.alarms.scheduledCount == 1)
    }

    @Test func macNeverSchedulesAlarms() async throws {
        let harness = try makeHarness(events: [wake], platform: .mac)
        await harness.scheduler.setDefaultStyle(.alarm, forCalendar: "wake")
        #expect(harness.scheduler.availableStyles == [.standard, .timeSensitive])
        #expect(harness.scheduler.defaultStyle(forCalendar: "wake") == .timeSensitive)
        #expect(harness.alarms.scheduleCount == 0)
        #expect(harness.center.pendingNotifications.map(\.style) == [.timeSensitive])
    }
}
