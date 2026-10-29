import Planner
import SwiftUI

struct WorkWeekSettingsView: View {
    @Environment(CalendarStore.self) private var store

    var body: some View {
        Form {
            WorkWeekDaysSection()
            if store.eventCalendars.isEmpty && store.reminderLists.isEmpty {
                Text(String(localized: "WorkWeek.Calendars.Empty", table: "Week"))
                    .foregroundStyle(.secondary)
            } else {
                WorkWeekCalendarsSection()
            }
        }
        .formStyle(.grouped)
        .navigationTitle(String(localized: "WorkWeek.Title", table: "Week"))
    }
}
