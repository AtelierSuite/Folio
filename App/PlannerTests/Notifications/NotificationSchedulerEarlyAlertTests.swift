import Foundation
import Testing
@testable import Planner

@MainActor
struct NotificationSchedulerEarlyAlertTests {
    @Test func savedEarlyAlertsAreScheduledAndClearingCancelsThem() async throws {
        let defaults = try #require(
            UserDefaults(suiteName: "NotificationSchedulerEarlyAlertTests.\(UUID().uuidString)")
        )
        let settings = NotificationSettings(defaults: defaults)
        settings.isEnabled = true
        let reminder = NotificationFixtures.reminder("trip", due: NotificationFixtures.hours(24 * 10), alarms: [])
        let center = FakeNotificationCenter()
        let scheduler = NotificationScheduler(
            source: FakeCalendarDataSource(reminders: [reminder]),
            center: center,
            alarmClient: FakeAlarmClient(),
            alarmLedger: AlarmLedger(defaults: defaults),
            settings: settings,
            styleSettings: NotificationStyleSettings(defaults: defaults),
            allDayAlertTimeSettings: AllDayAlertTimeSettings(defaults: defaults),
            earlyAlertSettings: ReminderEarlyAlertSettings(defaults: defaults),
            capabilities: PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: false),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            clock: { NotificationFixtures.now }
        )
        await scheduler.replan()
        #expect(center.pendingCount == 0)

        await scheduler.setEarlyAlerts([ReminderEarlyAlert(count: 3, unit: .days)], for: reminder.reference)
        #expect(center.pendingCount == 1)

        await scheduler.setEarlyAlerts([], for: reminder.reference)
        #expect(center.pendingCount == 0)
    }
}
