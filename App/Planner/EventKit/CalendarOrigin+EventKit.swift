import EventKit

extension CalendarOrigin {
    init?(_ calendar: EKCalendar?) {
        guard let calendar else { return nil }
        self.init(accountName: calendar.source?.displayTitle ?? "", calendarName: calendar.title)
    }
}
