import Foundation
@testable import Planner

enum NotificationFixtures {
    static let now = Fixtures.date(2026, 10, 29, hour: 8)

    static let formatter: NotificationContentFormatter = {
        NotificationContentFormatter(calendar: Fixtures.calendar, locale: Locale(identifier: "en_GB"))
    }()

    static func planner(reservedSlots: Int = NotificationPlanner.defaultReservedSlots) -> NotificationPlanner {
        NotificationPlanner(reservedSlots: reservedSlots, formatter: formatter)
    }

    static func event(
        _ local: String,
        start: Date,
        hours: Double = 1,
        alarms: [CalendarAlarm] = [.relative(offset: -600)],
        title: String? = nil,
        location: String? = nil,
        isAllDay: Bool = false,
        occurrence: Date? = nil,
        calendarIdentifier: String = "calendar-1"
    ) -> CalendarEvent {
        CalendarEvent(
            reference: Fixtures.reference(
                external: "external-\(local)",
                local: local,
                calendarIdentifier: calendarIdentifier,
                occurrence: occurrence,
                title: title ?? local,
                start: start
            ),
            calendarIdentifier: calendarIdentifier,
            title: title ?? local,
            location: location,
            startDate: start,
            endDate: start.addingTimeInterval(hours * 3600),
            isAllDay: isAllDay,
            isRecurring: occurrence != nil,
            alarms: alarms
        )
    }

    static func reminder(
        _ local: String,
        due: Date?,
        hasDueTime: Bool = true,
        alarms: [CalendarAlarm]? = nil,
        isCompleted: Bool = false,
        listIdentifier: String = "list-1"
    ) -> ReminderItem {
        ReminderItem(
            reference: Fixtures.reference(
                external: "external-\(local)",
                local: local,
                calendarIdentifier: listIdentifier,
                title: local,
                start: due
            ),
            listIdentifier: listIdentifier,
            title: local,
            dueDate: due,
            hasDueTime: hasDueTime,
            isCompleted: isCompleted,
            alarms: alarms ?? due.map { [.absolute(date: $0)] } ?? []
        )
    }

    static func hours(_ hours: Double, after date: Date = now) -> Date {
        date.addingTimeInterval(hours * 3600)
    }
}
