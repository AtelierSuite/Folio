import Foundation
import UserNotifications
@testable import Planner

enum NotificationActionFixtures {
    static let zoomURL = URL(string: "https://zoom.us/j/123")
    static let office = PlannerCoordinate(latitude: 35.6812, longitude: 139.7671)

    static func event(
        _ local: String = "call",
        start: Date = NotificationFixtures.hours(2),
        location: String? = nil,
        coordinate: PlannerCoordinate? = nil,
        notes: String? = nil,
        url: URL? = nil
    ) -> CalendarEvent {
        let base = NotificationFixtures.event(local, start: start, location: location)
        return CalendarEvent(
            reference: base.reference,
            calendarIdentifier: base.calendarIdentifier,
            title: base.title,
            location: location,
            coordinate: coordinate,
            notes: notes,
            url: url,
            startDate: base.startDate,
            endDate: base.endDate,
            alarms: base.alarms
        )
    }

    static func planned(_ event: CalendarEvent) -> PlannedNotification? {
        NotificationFixtures.planner()
            .plan(events: [event], reminders: [], after: NotificationFixtures.now, budget: 10)
            .first
    }

    static func plannedReminder(due: Date = NotificationFixtures.hours(1)) -> PlannedNotification? {
        NotificationFixtures.planner()
            .plan(events: [], reminders: [NotificationFixtures.reminder("milk", due: due)], after: NotificationFixtures.now, budget: 10)
            .first
    }

    static func content(_ notification: PlannedNotification) -> UNNotificationContent {
        UNNotificationContent.make(notification)
    }
}
