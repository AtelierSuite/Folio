import Foundation

public extension CalendarStore {
    var birthdayCalendar: PlannerCalendar? { eventCalendars.birthdayCalendar }

    func isBirthdayCalendar(_ calendar: PlannerCalendar) -> Bool {
        calendar.isBirthdays || markedBirthdayCalendarIdentifiers.contains(calendar.id)
    }

    /// The user's own calendars that can be marked as birthday calendars.
    var markableBirthdayCalendars: [PlannerCalendar] { eventCalendars.excludingBirthdays }

    func setMarkedAsBirthdays(
        _ isMarked: Bool,
        for calendar: PlannerCalendar,
        settings: BirthdaySettings = .shared
    ) async {
        if isMarked {
            markedBirthdayCalendarIdentifiers.insert(calendar.id)
        } else {
            markedBirthdayCalendarIdentifiers.remove(calendar.id)
        }
        settings.markedCalendarIdentifiers = markedBirthdayCalendarIdentifiers
        await handleExternalChange()
    }
}
