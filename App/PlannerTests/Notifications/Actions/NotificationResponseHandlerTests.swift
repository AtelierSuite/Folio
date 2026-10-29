import Foundation
import Testing
import UserNotifications
@testable import Planner

@MainActor
struct NotificationResponseHandlerTests {
    private let snoozes = FakeSnoozeClient()
    private let target = FakeNotificationResponseTarget()

    private func makeHandler() -> NotificationResponseHandler {
        NotificationResponseHandler(
            snoozes: snoozes,
            reminders: target,
            routing: target,
            replan: { [target] in target.replanCount += 1 },
            clock: { NotificationFixtures.now }
        )
    }

    private func reminderContent() throws -> (PlannedNotification, UNNotificationContent) {
        let notification = try #require(NotificationActionFixtures.plannedReminder())
        return (notification, NotificationActionFixtures.content(notification))
    }

    @Test func markDoneCompletesTheReminderAndReplans() async throws {
        let (notification, content) = try reminderContent()
        let handler = makeHandler()
        await handler.handle(actionIdentifier: NotificationAction.snoozeShort.identifier, content: content)
        await handler.handle(actionIdentifier: NotificationAction.markDone.identifier, content: content)
        #expect(target.completed == [notification.reference])
        #expect(snoozes.snoozes.isEmpty)
        #expect(target.routes.isEmpty)
        #expect(target.replanCount == 2)
    }

    @Test func snoozeSchedulesTheAlertAgain() async throws {
        let (_, content) = try reminderContent()
        await makeHandler().handle(actionIdentifier: NotificationAction.snoozeLong.identifier, content: content)
        #expect(snoozes.snoozes.map(\.fireDate) == [NotificationFixtures.now.addingTimeInterval(900)])
        #expect(target.replanCount == 1)
    }

    @Test func snoozesStayWithinTheReservedSlots() async throws {
        let handler = makeHandler()
        for index in 0..<6 {
            let event = NotificationActionFixtures.event("event-\(index)")
            let content = NotificationActionFixtures.content(try #require(NotificationActionFixtures.planned(event)))
            await handler.handle(actionIdentifier: NotificationAction.snoozeShort.identifier, content: content)
        }
        #expect(snoozes.snoozes.count == NotificationPlanner.defaultReservedSlots)
    }

    @Test func tappingOpensTheItem() async throws {
        let (notification, content) = try reminderContent()
        await makeHandler().handle(actionIdentifier: UNNotificationDefaultActionIdentifier, content: content)
        let destination = AppDestination.calendarDay(notification.fireDate, item: notification.reference)
        #expect(target.routes == [.item(destination, meetingURL: nil)])
        #expect(target.replanCount == 1)
    }

    @Test func foreignAlertsAreLeftAlone() async {
        let content = UNMutableNotificationContent()
        content.userInfo = ["other": true]
        await makeHandler().handle(actionIdentifier: UNNotificationDefaultActionIdentifier, content: content)
        #expect(target.routes.isEmpty)
        #expect(target.replanCount == 0)
    }
}
