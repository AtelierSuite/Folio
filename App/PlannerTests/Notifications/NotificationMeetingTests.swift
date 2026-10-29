import Foundation
import Testing
@testable import Planner

struct NotificationMeetingTests {
    private let start = NotificationFixtures.hours(2)

    private func plan(_ event: CalendarEvent) -> [PlannedNotification] {
        NotificationFixtures.planner().plan(events: [event], reminders: [], after: NotificationFixtures.now, budget: 10)
    }

    @Test func eventNotificationsCarryTheMeetingLink() throws {
        let event = NotificationFixtures.event("call", start: start, location: "https://meet.google.com/abc-defg-hij")
        let meeting = try #require(plan(event).first?.meeting)
        #expect(meeting.link.provider == .googleMeet)
        #expect(meeting.start == event.startDate)
        #expect(meeting.end == event.endDate)
    }

    @Test func eventsWithoutALinkHaveNoMeeting() {
        let event = NotificationFixtures.event("lunch", start: start, location: "Cafe")
        #expect(plan(event).first?.meeting == nil)
    }

    @Test func addingALinkReschedulesTheAlert() {
        let plain = NotificationFixtures.event("call", start: start, location: "Room 4")
        let linked = NotificationFixtures.event("call", start: start, location: "Room 4 https://zoom.us/j/1")
        #expect(plan(plain).first?.id != plan(linked).first?.id)
    }

    @Test func userInfoRoundTripsTheMeeting() throws {
        let event = NotificationFixtures.event("call", start: start, location: "https://zoom.us/j/1")
        let notification = try #require(plan(event).first)
        let userInfo = NotificationUserInfo.make(for: notification)
        #expect(NotificationUserInfo.meeting(from: userInfo) == notification.meeting)
        #expect(NotificationUserInfo.reference(from: userInfo) == event.reference)
    }

    @Test func meetingIsJoinableFromAnHourBeforeUntilItEnds() throws {
        let url = try #require(URL(string: "https://zoom.us/j/1"))
        let link = MeetingLink(provider: .zoom, url: url)
        let meeting = NotificationMeeting(link: link, start: start, end: start.addingTimeInterval(1800))
        #expect(!meeting.isJoinable(at: start.addingTimeInterval(-3601)))
        #expect(meeting.isJoinable(at: start.addingTimeInterval(-3600)))
        #expect(meeting.isJoinable(at: start.addingTimeInterval(900)))
        #expect(!meeting.isJoinable(at: start.addingTimeInterval(1801)))
    }
}
