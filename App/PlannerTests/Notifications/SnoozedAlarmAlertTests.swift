import Foundation
import Testing
@testable import Planner

@MainActor
struct SnoozedAlarmAlertTests {
    private struct Harness {
        let scheduler: NotificationScheduler
        let alarms: FakeAlarmClient
        let source: FakeCalendarDataSource
        let clock: MovableClock

        /// Rings the alarm-style alert, snoozes it, then replans after it rang.
        func ringAndSnooze() async throws -> UUID {
            let rung = try #require(alarms.scheduledAlarms.first)
            clock.move(to: rung.fireDate.addingTimeInterval(120))
            alarms.snooze(rung.id)
            await scheduler.replan()
            return rung.id
        }
    }

    private let wake = NotificationFixtures.event("wake", start: NotificationFixtures.hours(2))

    private func makeHarness() async throws -> Harness {
        let defaults = try #require(UserDefaults(suiteName: "SnoozedAlarmAlertTests.\(UUID().uuidString)"))
        let settings = NotificationSettings(defaults: defaults)
        settings.isEnabled = true
        let alarms = FakeAlarmClient()
        let source = FakeCalendarDataSource(events: [wake])
        let clock = MovableClock(NotificationFixtures.now)
        let scheduler = NotificationScheduler(
            source: source,
            center: FakeNotificationCenter(),
            alarmClient: alarms,
            alarmLedger: AlarmLedger(defaults: defaults),
            settings: settings,
            styleSettings: NotificationStyleSettings(defaults: defaults),
            allDayAlertTimeSettings: AllDayAlertTimeSettings(defaults: defaults),
            capabilities: PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: false),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            clock: { clock.now }
        )
        await scheduler.setStyleOverride(.alarm, for: wake.reference)
        return Harness(scheduler: scheduler, alarms: alarms, source: source, clock: clock)
    }

    @Test func aSnoozedAlarmWhoseEventStillExistsKeepsSnoozing() async throws {
        let harness = try await makeHarness()
        let snoozed = try await harness.ringAndSnooze()
        #expect(harness.alarms.snoozingIdentifiers == [snoozed])
        await harness.scheduler.replan()
        #expect(harness.alarms.snoozingIdentifiers == [snoozed])
        #expect(harness.alarms.cancelCount == 0)
    }

    @Test func deletingTheEventCancelsItsSnoozedAlarm() async throws {
        let harness = try await makeHarness()
        _ = try await harness.ringAndSnooze()
        harness.source.replaceEvents([])
        await harness.scheduler.replan()
        #expect(harness.alarms.snoozingIdentifiers.isEmpty)
    }

    @Test func removingTheAlertCancelsItsSnoozedAlarm() async throws {
        let harness = try await makeHarness()
        _ = try await harness.ringAndSnooze()
        harness.source.replaceEvents([
            NotificationFixtures.event("wake", start: NotificationFixtures.hours(2), alarms: [])
        ])
        await harness.scheduler.replan()
        #expect(harness.alarms.snoozingIdentifiers.isEmpty)
    }

    @Test func turningOffTheAlarmStyleCancelsItsSnoozedAlarm() async throws {
        let harness = try await makeHarness()
        _ = try await harness.ringAndSnooze()
        await harness.scheduler.setStyleOverride(.standard, for: wake.reference)
        #expect(harness.alarms.snoozingIdentifiers.isEmpty)
    }

    @Test func turningOffNotificationsCancelsASnoozedAlarm() async throws {
        let harness = try await makeHarness()
        _ = try await harness.ringAndSnooze()
        await harness.scheduler.setEnabled(false)
        #expect(harness.alarms.snoozingIdentifiers.isEmpty)
    }
}
