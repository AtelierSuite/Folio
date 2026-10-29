import Foundation

enum CalendarComposer: String, Identifiable {
    case newEvent
    case newReminder

    var id: Self { self }
}
