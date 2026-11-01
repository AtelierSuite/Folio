import Foundation
import Testing
import UserNotifications
@testable import Planner

struct NotificationDetailTests {
    private func detail(_ notification: PlannedNotification) -> NotificationDetail {
        let content = NotificationActionFixtures.content(notification)
        return NotificationDetail(title: content.title, body: content.body, userInfo: content.userInfo)
    }

    @Test func eventShowsItsTimePlaceAndColor() throws {
        let event = CalendarEvent(
            reference: Fixtures.reference(
                external: "e", local: "e", title: "Review", start: NotificationFixtures.hours(2)
            ),
            calendarIdentifier: "calendar-1",
            title: "Review",
            location: "Room 4",
            startDate: NotificationFixtures.hours(2),
            endDate: NotificationFixtures.hours(3),
            color: PlannerColor(red: 0.1, green: 0.5, blue: 0.9),
            alarms: [.relative(offset: -600)]
        )
        let notification = try #require(NotificationActionFixtures.planned(event))
        let detail = detail(notification)
        #expect(detail.title == "Review")
        #expect(detail.status == nil)
        #expect(detail.color == PlannerColor(red: 0.1, green: 0.5, blue: 0.9))
        #expect(detail.rows.map(\.kind) == [.time, .place])
        #expect(detail.rows.first?.text == notification.content.time)
        #expect(detail.rows.last?.text == "Room 4")
    }

    @Test func reminderShowsItsDueTime() throws {
        let notification = try #require(NotificationActionFixtures.plannedReminder())
        let detail = detail(notification)
        #expect(detail.rows.map(\.kind) == [.time])
        #expect(detail.rows.first?.systemImage == "bell")
    }

    @Test func olderAlertsFallBackToTheirBody() {
        let detail = NotificationDetail(title: "Lunch", body: "12:00 – 13:00", userInfo: [:])
        #expect(detail.rows == [NotificationDetailRow(kind: .time, text: "12:00 – 13:00", systemImage: "clock")])
    }
}
