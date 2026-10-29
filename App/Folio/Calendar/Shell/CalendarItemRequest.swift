import Foundation
import Planner

/// An event or reminder another feature asked to show, found by its reference around a date.
struct CalendarItemRequest: Hashable {
    let reference: CalendarItemReference
    let date: Date
}

enum CalendarPresentedItem: Identifiable {
    case event(CalendarEvent)
    case reminder(ReminderItem)

    var id: String {
        switch self {
        case .event(let event): "event.\(event.id)"
        case .reminder(let reminder): "reminder.\(reminder.id)"
        }
    }
}
