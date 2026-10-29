import Planner
import SwiftUI

struct CalendarVisibilityView: View {
    @Environment(CalendarStore.self) private var store

    var body: some View {
        Form {
            if store.eventCalendars.isEmpty && store.reminderLists.isEmpty {
                Text(String(localized: "Empty", table: "CalendarVisibility"))
                    .foregroundStyle(.secondary)
            }
            if !store.eventCalendars.isEmpty {
                Section(String(localized: "Section.Calendars", table: "CalendarVisibility")) {
                    ForEach(store.eventCalendars) { calendar in
                        CalendarVisibilityRow(calendar: calendar)
                    }
                }
            }
            if !store.reminderLists.isEmpty {
                Section(String(localized: "Section.ReminderLists", table: "CalendarVisibility")) {
                    ForEach(store.reminderLists) { calendar in
                        CalendarVisibilityRow(calendar: calendar)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(String(localized: "Title", table: "CalendarVisibility"))
    }
}
