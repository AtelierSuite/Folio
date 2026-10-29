import Foundation
@testable import Planner

enum Fixtures {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return calendar
    }()

    static func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour)) ?? .distantPast
    }

    static func reference(
        external: String? = "external-1",
        local: String = "local-1",
        calendarIdentifier: String = "calendar-1",
        occurrence: Date? = nil,
        title: String = "Standup",
        start: Date? = date(2026, 10, 29, hour: 9)
    ) -> CalendarItemReference {
        CalendarItemReference(
            externalIdentifier: external,
            localIdentifier: local,
            calendarIdentifier: calendarIdentifier,
            occurrenceDate: occurrence,
            title: title,
            startDate: start
        )
    }

    static func event(
        local: String,
        calendarIdentifier: String = "calendar-1",
        start: Date,
        hours: Double = 1
    ) -> CalendarEvent {
        CalendarEvent(
            reference: reference(external: "external-\(local)", local: local, calendarIdentifier: calendarIdentifier),
            calendarIdentifier: calendarIdentifier,
            title: local,
            startDate: start,
            endDate: start.addingTimeInterval(hours * 3600)
        )
    }

    static func reminder(local: String, listIdentifier: String = "list-1", due: Date?) -> ReminderItem {
        ReminderItem(
            reference: reference(external: "external-\(local)", local: local, calendarIdentifier: listIdentifier),
            listIdentifier: listIdentifier,
            title: local,
            dueDate: due
        )
    }

    static func plannerCalendar(_ identifier: String, kind: CalendarItemKind = .event) -> PlannerCalendar {
        PlannerCalendar(
            id: identifier,
            title: identifier,
            kind: kind,
            color: .gray,
            sourceIdentifier: "source",
            sourceTitle: "On My iPhone",
            sourceType: .local,
            isReadOnly: false
        )
    }
}
