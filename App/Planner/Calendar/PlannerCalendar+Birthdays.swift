import Foundation

public extension PlannerCalendar {
    var isBirthdays: Bool { sourceType == .birthdays }
}

public extension Array where Element == PlannerCalendar {
    var birthdayCalendar: PlannerCalendar? { first(where: \.isBirthdays) }

    var excludingBirthdays: [PlannerCalendar] { filter { !$0.isBirthdays } }
}
