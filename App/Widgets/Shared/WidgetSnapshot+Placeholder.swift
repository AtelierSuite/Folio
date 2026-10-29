import Foundation
import Planner

nonisolated extension WidgetSnapshot {
    /// Sample content for the widget gallery and redacted placeholders.
    static func placeholder(at now: Date) -> WidgetSnapshot {
        let start = Calendar.current.dateInterval(of: .hour, for: now)?.end ?? now
        let events = [
            sampleEvent("Placeholder.Event.Standup", start: start, hours: 0.5, color: .blue),
            sampleEvent("Placeholder.Event.Lunch", start: start.addingTimeInterval(7_200), hours: 1, color: .orange),
            sampleEvent("Placeholder.Event.Review", start: start.addingTimeInterval(14_400), hours: 1, color: .purple)
        ]
        let reminders = [
            sampleReminder("Placeholder.Reminder.Groceries", due: now),
            sampleReminder("Placeholder.Reminder.Call", due: now.addingTimeInterval(3_600)),
            sampleReminder("Placeholder.Reminder.Book", due: nil)
        ]
        return WidgetSnapshot(events: events, reminders: reminders)
    }

    private static func sampleEvent(_ key: String.LocalizationValue, start: Date, hours: Double, color: PlannerColor) -> CalendarEvent {
        let title = String(localized: key, table: "Widgets")
        return CalendarEvent(
            reference: CalendarItemReference(externalIdentifier: nil, localIdentifier: title, calendarIdentifier: "", title: title),
            calendarIdentifier: "",
            title: title,
            startDate: start,
            endDate: start.addingTimeInterval(hours * 3_600),
            color: color
        )
    }

    private static func sampleReminder(_ key: String.LocalizationValue, due: Date?) -> ReminderItem {
        let title = String(localized: key, table: "Widgets")
        return ReminderItem(
            reference: CalendarItemReference(externalIdentifier: nil, localIdentifier: title, calendarIdentifier: "", title: title),
            listIdentifier: "",
            title: title,
            dueDate: due,
            hasDueTime: due != nil,
            color: .orange
        )
    }
}

nonisolated private extension PlannerColor {
    static let blue = PlannerColor(red: 0.0, green: 0.48, blue: 1.0)
    static let orange = PlannerColor(red: 1.0, green: 0.58, blue: 0.0)
    static let purple = PlannerColor(red: 0.69, green: 0.32, blue: 0.87)
}
