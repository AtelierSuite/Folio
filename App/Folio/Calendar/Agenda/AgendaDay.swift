import Foundation
import Planner

struct AgendaDay: Identifiable {
    let interval: DateInterval
    let eventGroups: [EventDuplicateGroup]
    let reminders: [ReminderItem]

    var events: [CalendarEvent] {
        eventGroups.map(\.primary)
    }

    var id: Date {
        interval.start
    }

    var isEmpty: Bool {
        eventGroups.isEmpty && reminders.isEmpty
    }

    static func upcomingInterval(dayCount: Int, calendar: Calendar = .current) -> DateInterval {
        let start = calendar.startOfDay(for: .now)
        let end = calendar.date(byAdding: .day, value: dayCount, to: start) ?? start
        return DateInterval(start: start, end: end)
    }

    static func days(
        in interval: DateInterval,
        events: [CalendarEvent],
        reminders: [ReminderItem],
        calendar: Calendar = .current
    ) -> [AgendaDay] {
        let eventGroups = EventDuplicateDetector(calendar: calendar).groups(in: events)
        var days: [AgendaDay] = []
        var dayStart = interval.start
        while dayStart < interval.end {
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? interval.end
            let dayInterval = DateInterval(start: dayStart, end: dayEnd)
            days.append(AgendaDay(
                interval: dayInterval,
                eventGroups: eventGroups.filter { $0.primary.overlaps(dayInterval) },
                reminders: reminders.filter { $0.isDue(in: dayInterval) }
            ))
            dayStart = dayEnd
        }
        return days
    }
}
