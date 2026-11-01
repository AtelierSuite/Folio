import Planner
import SwiftUI

struct WorkWeekCalendarsSection: View {
    @Environment(CalendarStore.self) private var store

    var body: some View {
        CalendarAccountSections(
            calendars: store.eventCalendars,
            kindTitle: String(localized: "WorkWeek.Section.Calendars", table: "Week"),
            footer: String(localized: "WorkWeek.Section.Calendars.Footer", table: "Week")
        ) { calendar in
            WorkWeekCalendarRow(calendar: calendar)
        }
        CalendarAccountSections(
            calendars: store.reminderLists,
            kindTitle: String(localized: "WorkWeek.Section.ReminderLists", table: "Week")
        ) { calendar in
            WorkWeekCalendarRow(calendar: calendar)
        }
    }
}
