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

    @Test func alertCarriesItsAccountAndCalendarNames() throws {
        let origin = CalendarOrigin(accountName: "iCloud", calendarName: "Work")
        let event = CalendarEvent(
            reference: Fixtures.reference(
                external: "e", local: "e", title: "Review", start: NotificationFixtures.hours(2)
            ),
            calendarIdentifier: "calendar-1",
            title: "Review",
            startDate: NotificationFixtures.hours(2),
            endDate: NotificationFixtures.hours(3),
            alarms: [.relative(offset: -600)],
            origin: origin
        )
        let notification = try #require(NotificationActionFixtures.planned(event))
        #expect(detail(notification).origin == origin)
    }

    @Test func renamingACalendarReschedulesItsAlerts() {
        let start = NotificationFixtures.hours(2)
        let alerts = ["Work", "Office"].map { name in
            CalendarEvent(
                reference: Fixtures.reference(external: "e", local: "e", title: "Review", start: start),
                calendarIdentifier: "calendar-1",
                title: "Review",
                startDate: start,
                endDate: start.addingTimeInterval(3600),
                alarms: [.relative(offset: -600)],
                origin: CalendarOrigin(accountName: "iCloud", calendarName: name)
            )
        }.compactMap(NotificationActionFixtures.planned)
        #expect(alerts.count == 2)
        #expect(alerts.first?.id != alerts.last?.id)
    }

    @Test func timedEventWorksOutItsStatusWhenRead() throws {
        let start = NotificationFixtures.hours(2)
        let event = NotificationFixtures.event("e", start: start)
        let notification = try #require(NotificationActionFixtures.planned(event))
        let detail = detail(notification)
        #expect(detail.hasStatus)
        let before = detail.status(at: start.addingTimeInterval(-600))
        let after = detail.status(at: start.addingTimeInterval(600))
        #expect(before != nil)
        #expect(before != after)
    }

    @Test func allDayEventHasNoLiveStatus() throws {
        let start = NotificationFixtures.hours(24)
        let event = NotificationFixtures.event("e", start: start, hours: 24, isAllDay: true)
        let notification = try #require(NotificationActionFixtures.planned(event))
        #expect(!detail(notification).hasStatus)
    }

    @Test func reminderHasNoLiveStatus() throws {
        let notification = try #require(NotificationActionFixtures.plannedReminder())
        #expect(!detail(notification).hasStatus)
    }

    @Test func fixedStatusWinsOverTheLiveOne() {
        let content = NotificationContent(
            title: "Review", body: "", status: "Leave by 9:00", startDate: NotificationFixtures.hours(1)
        )
        let userInfo = NotificationUserInfo.make(for: content)
        let detail = NotificationDetail(title: "Review", body: "", userInfo: userInfo)
        #expect(detail.status(at: NotificationFixtures.now) == "Leave by 9:00")
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
