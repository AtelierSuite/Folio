import Planner
import SwiftUI

struct WorkWeekCalendarsSection: View {
    @Environment(CalendarStore.self) private var store

    var body: some View {
        if !store.eventCalendars.isEmpty {
            Section {
                ForEach(store.eventCalendars) { calendar in
                    WorkWeekCalendarRow(calendar: calendar)
                }
            } header: {
                Text(String(localized: "WorkWeek.Section.Calendars", table: "Week"))
            } footer: {
                Text(String(localized: "WorkWeek.Section.Calendars.Footer", table: "Week"))
            }
        }
        if !store.reminderLists.isEmpty {
            Section(String(localized: "WorkWeek.Section.ReminderLists", table: "Week")) {
                ForEach(store.reminderLists) { calendar in
                    WorkWeekCalendarRow(calendar: calendar)
                }
            }
        }
    }
}
