import Foundation

enum CalendarComposer: String, Identifiable {
    case newEvent
    case newReminder
    case newAlarm

    var id: Self { self }
}
