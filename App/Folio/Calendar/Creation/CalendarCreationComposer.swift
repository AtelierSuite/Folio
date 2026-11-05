import Foundation
import Planner

enum CalendarCreationComposer: Identifiable {
    case event(EventDraft)
    case reminder(CalendarCreationSlot)
    case alarm(CalendarCreationSlot)

    var id: String {
        switch self {
        case .event(let draft): "event.\(draft.startDate.timeIntervalSinceReferenceDate)"
        case .reminder(let slot): "reminder.\(slot.date.timeIntervalSinceReferenceDate)"
        case .alarm(let slot): "alarm.\(slot.date.timeIntervalSinceReferenceDate)"
        }
    }

    static func event(at slot: CalendarCreationSlot, calendar: Calendar) -> CalendarCreationComposer {
        var draft = EventDraft.newEvent(
            on: slot.date,
            calendarIdentifier: "",
            location: EventLocationSettings().defaultLocation,
            calendar: calendar
        )
        if slot.hasTime {
            draft.moveStart(to: slot.date)
        }
        return .event(draft)
    }
}
