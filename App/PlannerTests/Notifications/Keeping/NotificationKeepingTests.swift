import Foundation
import Testing
import UserNotifications
@testable import Planner

@MainActor
struct NotificationKeepingTests {
    private let keeper = FakeKeepClient()
    private let snoozes = CapturingSnoozeClient()
    private let target = FakeNotificationResponseTarget()

    private func makeHandler(keeps: Bool = true, now: Date = NotificationFixtures.now) -> NotificationResponseHandler {
        NotificationResponseHandler(
            snoozes: snoozes,
            keeper: keeper,
            reminders: target,
            routing: target,
            replan: {},
            clock: { now },
            snoozeDurations: { .standard },
            keepsEventAlerts: { keeps }
        )
    }

    private func eventContent() throws -> (PlannedNotification, UNNotificationContent) {
        let event = NotificationActionFixtures.event()
        let notification = try #require(NotificationActionFixtures.planned(event))
        return (notification, NotificationActionFixtures.content(notification))
    }

    @Test func tappingAnEventAlertKeepsASilentCopy() async throws {
        let (notification, content) = try eventContent()
        await makeHandler().handle(actionIdentifier: UNNotificationDefaultActionIdentifier, content: content)
        let kept = try #require(keeper.kept.first)
        #expect(keeper.kept.count == 1)
        #expect(kept.identifier.hasPrefix(NotificationItem.keptPrefix))
        #expect(!NotificationIdentifier.isOwned(kept.identifier))
        #expect(kept.content.sound == nil)
        #expect(kept.content.interruptionLevel == .passive)
        #expect(kept.content.title == content.title)
        #expect(kept.content.categoryIdentifier == content.categoryIdentifier)
        #expect(NotificationUserInfo.isKept(kept.content.userInfo))
        #expect(NotificationUserInfo.endDate(from: kept.content.userInfo) == notification.endDate)
        #expect(target.routes.count == 1)
    }

    @Test func openingActionsKeepTheAlert() async throws {
        let (_, content) = try eventContent()
        await makeHandler().handle(actionIdentifier: NotificationAction.openNote.identifier, content: content)
        #expect(keeper.kept.count == 1)
    }

    @Test func tappingAKeptCopyKeepsItAgainUnderTheSameIdentifier() async throws {
        let (_, content) = try eventContent()
        let handler = makeHandler()
        await handler.handle(actionIdentifier: UNNotificationDefaultActionIdentifier, content: content)
        let first = try #require(keeper.kept.first)
        await handler.handle(actionIdentifier: UNNotificationDefaultActionIdentifier, content: first.content)
        #expect(keeper.kept.map(\.identifier) == [first.identifier, first.identifier])
        let level = NotificationUserInfo.keptInterruptionLevel(from: keeper.kept[1].content.userInfo)
        #expect(level == content.interruptionLevel)
    }

    @Test func nothingIsKeptWhenTheSettingIsOff() async throws {
        let (_, content) = try eventContent()
        await makeHandler(keeps: false)
            .handle(actionIdentifier: UNNotificationDefaultActionIdentifier, content: content)
        #expect(keeper.kept.isEmpty)
    }

    @Test func snoozingDoesNotKeepTheAlert() async throws {
        let (_, content) = try eventContent()
        await makeHandler().handle(actionIdentifier: NotificationAction.snoozeShort.identifier, content: content)
        #expect(keeper.kept.isEmpty)
        #expect(snoozes.scheduledContents.count == 1)
    }

    @Test func remindersAreNotKept() async throws {
        let notification = try #require(NotificationActionFixtures.plannedReminder())
        await makeHandler().handle(
            actionIdentifier: UNNotificationDefaultActionIdentifier,
            content: NotificationActionFixtures.content(notification)
        )
        #expect(keeper.kept.isEmpty)
    }

    @Test func endedEventsAreNotKept() async throws {
        let (notification, content) = try eventContent()
        let endDate = try #require(notification.endDate)
        await makeHandler(now: endDate)
            .handle(actionIdentifier: UNNotificationDefaultActionIdentifier, content: content)
        #expect(keeper.kept.isEmpty)
    }

    @Test func snoozingAKeptCopyBringsBackTheAlert() async throws {
        let (_, content) = try eventContent()
        await makeHandler().handle(
            actionIdentifier: NotificationAction.snoozeShort.identifier,
            content: content.keptCopy()
        )
        let snoozed = try #require(snoozes.scheduledContents.first)
        #expect(snoozed.sound != nil)
        #expect(snoozed.interruptionLevel == content.interruptionLevel)
        #expect(!NotificationUserInfo.isKept(snoozed.userInfo))
    }

    @Test func snoozingAnOrdinaryAlertLeavesItsContentAlone() async throws {
        let (_, content) = try eventContent()
        await makeHandler().handle(actionIdentifier: NotificationAction.snoozeShort.identifier, content: content)
        #expect(snoozes.scheduledContents.first === content)
    }
}
