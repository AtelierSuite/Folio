import Foundation
import Testing
import UserNotifications
@testable import Planner

struct NotificationCategoryActionTests {
    @Test func eventCategoryFollowsWhatTheEventOffers() throws {
        let url = try #require(NotificationActionFixtures.zoomURL)
        let place = NotificationPlace(name: "Room 4", coordinate: nil)
        #expect(NotificationCategory(.event) == .event)
        #expect(NotificationCategory(.event, context: NotificationActionContext(meetingURL: url)) == .eventWithMeeting)
        #expect(NotificationCategory(.event, context: NotificationActionContext(place: place)) == .eventWithPlace)
        #expect(
            NotificationCategory(.event, context: NotificationActionContext(meetingURL: url, place: place))
                == .eventWithMeetingAndPlace
        )
        #expect(NotificationCategory(.reminder, context: NotificationActionContext(meetingURL: url)) == .reminder)
    }

    @Test func categoriesOfferMatchingActions() {
        #expect(NotificationCategory.event.actions == [.snoozeShort, .snoozeLong, .openNote])
        #expect(NotificationCategory.eventWithMeeting.actions.first == .joinMeeting)
        #expect(NotificationCategory.eventWithPlace.actions.first == .directions)
        #expect(NotificationCategory.eventWithMeetingAndPlace.actions.prefix(2) == [.joinMeeting, .directions])
        #expect(NotificationCategory.reminder.actions == [.markDone, .snoozeShort, .snoozeLong, .openNote])
        for category in NotificationCategory.allCases where category.kind == .event {
            #expect(!category.actions.contains(.markDone))
        }
    }

    @Test func markDoneAndSnoozeStayInTheBackground() {
        #expect(!NotificationAction.markDone.opensApp)
        #expect(!NotificationAction.snoozeShort.opensApp)
        #expect(!NotificationAction.snoozeLong.opensApp)
        #expect(NotificationAction.joinMeeting.opensApp)
        #expect(NotificationAction.directions.opensApp)
        #expect(NotificationAction.openNote.opensApp)
    }

    @Test func snoozeDurations() {
        #expect(NotificationAction.snoozeShort.snoozeDuration == 300)
        #expect(NotificationAction.snoozeLong.snoozeDuration == 900)
        #expect(NotificationAction.markDone.snoozeDuration == nil)
    }

    @Test func registeredCategoriesCarryTheirActions() {
        let category = NotificationCategoryRegistry.makeCategory(.reminder)
        #expect(category.identifier == "folio.reminder")
        #expect(category.actions.map(\.identifier) == NotificationCategory.reminder.actions.map(\.identifier))
        #expect(category.actions.first?.options.contains(.foreground) == false)
        let note = NotificationCategoryRegistry.makeCategory(.event).actions.last
        #expect(note?.options.contains(.foreground) == true)
    }

    @Test func variantsShareTheirKindsThread() {
        #expect(NotificationCategory.eventWithMeetingAndPlace.threadIdentifier == "folio.event")
        #expect(NotificationCategory.reminder.threadIdentifier == "folio.reminder")
    }
}
