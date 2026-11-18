import Foundation

public extension PlannerCalendar {
    var isBirthdays: Bool { sourceType == .birthdays }
}

public extension Array where Element == PlannerCalendar {
    var birthdayCalendar: PlannerCalendar? { first(where: \.isBirthdays) }

    var excludingBirthdays: [PlannerCalendar] { filter { !$0.isBirthdays } }
}

public extension Array where Element == CalendarEvent {
    /// Birthdays first, keeping the order within each group.
    var birthdaysFirst: [CalendarEvent] { filter(\.isBirthday) + filter { !$0.isBirthday } }
}
