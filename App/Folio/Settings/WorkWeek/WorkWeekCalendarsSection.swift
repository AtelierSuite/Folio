import Planner
import SwiftUI

struct WorkWeekCalendarsSection: View {
    @Environment(CalendarStore.self) private var store

    var body: some View {
        CalendarAccountSections(
            calendars: store.eventCalendars,
            lists: store.reminderLists,
            footer: String(localized: "WorkWeek.Section.Calendars.Footer", table: "Week")
        ) { calendar in
            WorkWeekCalendarRow(calendar: calendar)
        }
    }
}
