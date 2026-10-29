import Foundation
import Testing
@testable import Planner

@MainActor
struct NotificationSchedulerTests {
    private func makeDefaults() throws -> UserDefaults {
        try #require(UserDefaults(suiteName: "NotificationSchedulerTests.\(UUID().uuidString)"))
    }

    private func makeScheduler(
        source: FakeCalendarDataSource,
        center: FakeNotificationCenter,
        defaults: UserDefaults,
        isEnabled: Bool = true
    ) -> NotificationScheduler {
        let settings = NotificationSettings(defaults: defaults)
        settings.isEnabled = isEnabled
        return NotificationScheduler(
            source: source,
            center: center,
            settings: settings,
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            planner: NotificationFixtures.planner(),
            clock: { NotificationFixtures.now }
        )
    }

    private func events(_ count: Int, prefix: String = "event") -> [CalendarEvent] {
        (0..<count).map { NotificationFixtures.event("\(prefix)-\($0)", start: NotificationFixtures.hours(Double($0) + 1)) }
    }

    @Test func disabledSchedulerSchedulesNothingAndNeverAsksForPermission() async throws {
        let center = FakeNotificationCenter(authorization: .notDetermined)
        let scheduler = makeScheduler(
            source: FakeCalendarDataSource(events: events(5)), center: center, defaults: try makeDefaults(), isEnabled: false
        )
        await scheduler.replan()
        #expect(center.pendingCount == 0)
        #expect(center.authorizationRequestCount == 0)
        #expect(scheduler.lastReport?.scheduledCount == 0)
    }

    @Test func enablingRequestsPermissionOnceThenSchedules() async throws {
        let center = FakeNotificationCenter(authorization: .notDetermined)
        let defaults = try makeDefaults()
        let scheduler = makeScheduler(
            source: FakeCalendarDataSource(events: events(3)), center: center, defaults: defaults, isEnabled: false
        )
        #expect(await scheduler.setEnabled(true))
        #expect(center.authorizationRequestCount == 1)
        #expect(center.pendingCount == 3)
        #expect(NotificationSettings(defaults: defaults).isEnabled)

        await scheduler.setEnabled(false)
        #expect(center.pendingCount == 0)
        await scheduler.setEnabled(true)
        #expect(center.authorizationRequestCount == 1)
    }

    @Test func deniedPermissionLeavesNotificationsOff() async throws {
        let center = FakeNotificationCenter(authorization: .notDetermined)
        center.setAuthorization(.notDetermined, afterRequest: .denied)
        let defaults = try makeDefaults()
        let scheduler = makeScheduler(
            source: FakeCalendarDataSource(events: events(3)), center: center, defaults: defaults, isEnabled: false
        )
        #expect(await scheduler.setEnabled(true) == false)
        #expect(!scheduler.isEnabled)
        #expect(scheduler.authorization == .denied)
        #expect(center.pendingCount == 0)
        #expect(!NotificationSettings(defaults: defaults).isEnabled)
    }

    @Test func hundredsOfItemsNeverExceedTheLimit() async throws {
        let reminders = (0..<200).map { NotificationFixtures.reminder("reminder-\($0)", due: NotificationFixtures.hours(Double($0) + 0.5)) }
        let center = FakeNotificationCenter()
        let scheduler = makeScheduler(
            source: FakeCalendarDataSource(events: events(400), reminders: reminders), center: center, defaults: try makeDefaults()
        )
        await scheduler.replan()
        #expect(center.pendingCount == 60)
        #expect(center.maximumPendingCount <= 64)
        #expect(center.pendingNotifications.first?.content.title == "reminder-0")
        #expect(scheduler.lastReport?.nextFireDate == NotificationFixtures.hours(0.5))
    }

    @Test func foreignRequestsShrinkTheBudgetSoTheTotalStaysWithinTheLimit() async throws {
        let foreign = (0..<10).map { "folio.snooze.\($0)" }
        let center = FakeNotificationCenter(foreignIdentifiers: foreign)
        let scheduler = makeScheduler(
            source: FakeCalendarDataSource(events: events(200)), center: center, defaults: try makeDefaults()
        )
        await scheduler.replan()
        #expect(center.pendingCount == 64)
        #expect(center.pendingNotifications.count == 54)
        #expect(center.maximumPendingCount == 64)
        #expect(scheduler.lastReport?.pendingCount == 64)
    }

    @Test func replanningAppliesOnlyTheDiff() async throws {
        let source = FakeCalendarDataSource(events: events(10))
        let center = FakeNotificationCenter()
        let scheduler = makeScheduler(source: source, center: center, defaults: try makeDefaults())
        await scheduler.replan()
        #expect(center.addCount == 10)

        await scheduler.replan()
        #expect(center.addCount == 10)
        #expect(center.removeCount == 0)

        var changed = events(10)
        changed[3] = NotificationFixtures.event("event-3", start: NotificationFixtures.hours(30))
        changed.remove(at: 7)
        source.replaceEvents(changed)
        await scheduler.replan()
        #expect(center.addCount == 11)
        #expect(center.removeCount == 2)
        #expect(center.pendingNotifications.map(\.content.title).last == "event-3")
        #expect(!center.pendingNotifications.map(\.content.title).contains("event-7"))
    }

    @Test func revokedPermissionClearsOwnRequestsOnly() async throws {
        let center = FakeNotificationCenter(foreignIdentifiers: ["other"])
        let scheduler = makeScheduler(
            source: FakeCalendarDataSource(events: events(5)), center: center, defaults: try makeDefaults()
        )
        await scheduler.replan()
        #expect(center.pendingCount == 6)
        center.setAuthorization(.denied, afterRequest: .denied)
        await scheduler.replan()
        #expect(center.pendingCount == 1)
        #expect(scheduler.authorization == .denied)
    }

    @Test func respectsHiddenCalendarsAndItemKindSwitches() async throws {
        let defaults = try makeDefaults()
        CalendarVisibilityStorage(defaults: defaults).hiddenCalendarIdentifiers = ["hidden"]
        let source = FakeCalendarDataSource(
            events: [
                NotificationFixtures.event("visible", start: NotificationFixtures.hours(1)),
                NotificationFixtures.event("secret", start: NotificationFixtures.hours(2), calendarIdentifier: "hidden")
            ],
            reminders: [NotificationFixtures.reminder("task", due: NotificationFixtures.hours(3))]
        )
        let center = FakeNotificationCenter()
        let scheduler = makeScheduler(source: source, center: center, defaults: defaults)
        await scheduler.replan()
        #expect(center.pendingNotifications.map(\.content.title) == ["visible", "task"])

        await scheduler.setIncludesReminders(false)
        #expect(center.pendingNotifications.map(\.content.title) == ["visible"])
        await scheduler.setIncludesEvents(false)
        #expect(center.pendingCount == 0)
        #expect(!NotificationSettings(defaults: defaults).includesEvents)
    }

    @Test func calendarChangesTriggerAReplan() async throws {
        let source = FakeCalendarDataSource(events: events(2))
        let center = FakeNotificationCenter()
        let scheduler = makeScheduler(source: source, center: center, defaults: try makeDefaults())
        scheduler.startObservingChanges(debounce: .zero)
        defer { scheduler.stopObservingChanges() }
        await scheduler.replan()
        #expect(center.pendingCount == 2)

        source.replaceEvents(events(5))
        source.postChange()
        let deadline = ContinuousClock.now + .seconds(5)
        while center.pendingCount != 5, ContinuousClock.now < deadline {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(center.pendingCount == 5)
    }

    @Test func overlappingReplansConvergeOnTheLatestState() async throws {
        let source = FakeCalendarDataSource(events: events(3))
        let center = FakeNotificationCenter()
        let scheduler = makeScheduler(source: source, center: center, defaults: try makeDefaults())
        async let first: Void = scheduler.replan()
        source.replaceEvents(events(8, prefix: "moved"))
        async let second: Void = scheduler.replan()
        async let third: Void = scheduler.replan()
        _ = await (first, second, third)
        #expect(center.pendingNotifications.map(\.content.title) == (0..<8).map { "moved-\($0)" })
        #expect(center.maximumPendingCount <= 64)
    }
}
