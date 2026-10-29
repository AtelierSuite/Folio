import Foundation
import Testing
import UserNotifications
@testable import Planner

struct NotificationResponseRouterTests {
    private let meetingStart = NotificationFixtures.hours(2)

    private func userInfo(_ notification: PlannedNotification?) throws -> [AnyHashable: Any] {
        NotificationUserInfo.make(for: try #require(notification))
    }

    private func meeting(location: String? = nil) throws -> [AnyHashable: Any] {
        try userInfo(NotificationActionFixtures.planned(NotificationActionFixtures.event(
            start: meetingStart, location: location, url: NotificationActionFixtures.zoomURL
        )))
    }

    @Test func tappingAMeetingAlertOpensTheEventThenTheLink() throws {
        let router = NotificationResponseRouter(now: meetingStart.addingTimeInterval(-600))
        let outcome = router.outcome(actionIdentifier: UNNotificationDefaultActionIdentifier, userInfo: try meeting())
        guard case .open(.item(.calendarDay(let date, let item), let meetingURL)) = outcome else {
            Issue.record("Expected to open the event, got \(String(describing: outcome))")
            return
        }
        #expect(date == meetingStart)
        #expect(item?.localIdentifier == "call")
        #expect(meetingURL == NotificationActionFixtures.zoomURL)
    }

    @Test func tappingLongBeforeTheMeetingOnlyOpensTheEvent() throws {
        let router = NotificationResponseRouter(now: meetingStart.addingTimeInterval(-2 * 3600))
        let outcome = router.outcome(actionIdentifier: UNNotificationDefaultActionIdentifier, userInfo: try meeting())
        guard case .open(.item(_, let meetingURL)) = outcome else {
            Issue.record("Expected to open the event")
            return
        }
        #expect(meetingURL == nil)
    }

    @Test func tappingAfterTheMeetingEndedOnlyOpensTheEvent() throws {
        let router = NotificationResponseRouter(now: meetingStart.addingTimeInterval(2 * 3600))
        let outcome = router.outcome(actionIdentifier: UNNotificationDefaultActionIdentifier, userInfo: try meeting())
        guard case .open(.item(_, let meetingURL)) = outcome else {
            Issue.record("Expected to open the event")
            return
        }
        #expect(meetingURL == nil)
    }

    @Test func joinOpensTheMeetingLink() throws {
        let router = NotificationResponseRouter(now: NotificationFixtures.now)
        let outcome = router.outcome(
            actionIdentifier: NotificationAction.joinMeeting.identifier, userInfo: try meeting()
        )
        #expect(outcome == .open(.url(try #require(NotificationActionFixtures.zoomURL))))
    }

    @Test func directionsOpenMaps() throws {
        let router = NotificationResponseRouter(now: NotificationFixtures.now)
        let outcome = router.outcome(
            actionIdentifier: NotificationAction.directions.identifier, userInfo: try meeting(location: "Room 4")
        )
        guard case .open(.url(let url)) = outcome else {
            Issue.record("Expected a Maps link")
            return
        }
        #expect(url.host() == "maps.apple.com")
    }

    @Test func markDoneCompletesReminders() throws {
        let notification = try #require(NotificationActionFixtures.plannedReminder())
        let router = NotificationResponseRouter(now: NotificationFixtures.now)
        let markDone = NotificationAction.markDone.identifier
        let outcome = router.outcome(actionIdentifier: markDone, userInfo: try userInfo(notification))
        guard case .markDone(let item) = outcome else {
            Issue.record("Expected Mark Done")
            return
        }
        #expect(item.reference == notification.reference)
        #expect(router.outcome(actionIdentifier: markDone, userInfo: try meeting()) == nil)
    }

    @Test func snoozeFiresAgainAfterItsDuration() throws {
        let router = NotificationResponseRouter(now: NotificationFixtures.now)
        let userInfo = try meeting()
        let short = router.outcome(actionIdentifier: NotificationAction.snoozeShort.identifier, userInfo: userInfo)
        let long = router.outcome(actionIdentifier: NotificationAction.snoozeLong.identifier, userInfo: userInfo)
        guard case .snooze(let shortSnooze) = short, case .snooze(let longSnooze) = long else {
            Issue.record("Expected snoozes")
            return
        }
        #expect(shortSnooze.fireDate == NotificationFixtures.now.addingTimeInterval(300))
        #expect(longSnooze.fireDate == NotificationFixtures.now.addingTimeInterval(900))
        #expect(shortSnooze.identifier == longSnooze.identifier)
        #expect(NotificationSnooze.isSnooze(shortSnooze.identifier))
        #expect(!NotificationIdentifier.isOwned(shortSnooze.identifier))
    }

    @Test func openNoteOpensTheEventNoteOrTheDailyNote() throws {
        let router = NotificationResponseRouter(now: NotificationFixtures.now)
        let openNote = NotificationAction.openNote.identifier
        let eventOutcome = router.outcome(actionIdentifier: openNote, userInfo: try meeting())
        guard case .open(.note(.event(let reference, let date))) = eventOutcome else {
            Issue.record("Expected the event's note")
            return
        }
        #expect(reference.localIdentifier == "call")
        #expect(date == meetingStart)
        let due = NotificationFixtures.hours(1)
        let reminder = try userInfo(NotificationActionFixtures.plannedReminder(due: due))
        let reminderOutcome = router.outcome(actionIdentifier: openNote, userInfo: reminder)
        #expect(reminderOutcome == .open(.note(.dailyNote(due))))
    }

    @Test func dismissalsAndForeignAlertsAreIgnored() throws {
        let router = NotificationResponseRouter(now: NotificationFixtures.now)
        let userInfo = try meeting()
        #expect(router.outcome(actionIdentifier: UNNotificationDismissActionIdentifier, userInfo: userInfo) == nil)
        #expect(router.outcome(actionIdentifier: UNNotificationDefaultActionIdentifier, userInfo: [:]) == nil)
        #expect(router.outcome(actionIdentifier: "folio.action.unknown", userInfo: userInfo) == nil)
    }
}
