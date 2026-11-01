import Foundation
import Testing
@testable import Planner

@MainActor
struct NotificationEndedDismissalTests {
    private func makeScheduler(center: FakeNotificationCenter) throws -> NotificationScheduler {
        let defaults = try #require(UserDefaults(suiteName: "NotificationEndedDismissalTests.\(UUID().uuidString)"))
        return NotificationScheduler(
            source: FakeCalendarDataSource(events: []),
            center: center,
            alarmClient: FakeAlarmClient(),
            alarmLedger: AlarmLedger(defaults: defaults),
            settings: NotificationSettings(defaults: defaults),
            styleSettings: NotificationStyleSettings(defaults: defaults),
            capabilities: PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: true),
            visibilityStorage: CalendarVisibilityStorage(defaults: defaults),
            planner: NotificationFixtures.planner(),
            clock: { NotificationFixtures.now }
        )
    }

    @Test func replanningDismissesDeliveredAlertsForEventsThatHaveEnded() async throws {
        let center = FakeNotificationCenter()
        center.deliver("ended", endDate: NotificationFixtures.hours(-1))
        center.deliver("endingNow", endDate: NotificationFixtures.now)
        center.deliver("ongoing", endDate: NotificationFixtures.hours(1))
        center.deliver("reminder", endDate: nil)
        let scheduler = try makeScheduler(center: center)

        await scheduler.replan()

        #expect(center.deliveredIdentifiers == ["ongoing", "reminder"])
    }

    @Test func eventAlertsCarryTheEventEndButReminderAlertsDoNot() throws {
        let event = NotificationFixtures.event("standup", start: NotificationFixtures.hours(1), hours: 0.5)
        let reminder = NotificationFixtures.reminder("milk", due: NotificationFixtures.hours(1))
        let planned = NotificationFixtures.planner().plan(
            events: [event], reminders: [reminder], after: NotificationFixtures.now, budget: 10
        )
        let eventAlert = try #require(planned.first { $0.kind == .event })
        let reminderAlert = try #require(planned.first { $0.kind == .reminder })

        #expect(NotificationUserInfo.endDate(from: NotificationUserInfo.make(for: eventAlert)) == event.endDate)
        #expect(NotificationUserInfo.endDate(from: NotificationUserInfo.make(for: reminderAlert)) == nil)
    }
}
