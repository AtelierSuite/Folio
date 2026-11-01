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
            CalendarAccountSections(
                calendars: store.eventCalendars,
                kindTitle: String(localized: "Section.Calendars", table: "CalendarVisibility")
            ) { calendar in
                CalendarVisibilityRow(calendar: calendar)
            }
            CalendarAccountSections(
                calendars: store.reminderLists,
                kindTitle: String(localized: "Section.ReminderLists", table: "CalendarVisibility")
            ) { calendar in
                CalendarVisibilityRow(calendar: calendar)
            }
        }
        .formStyle(.grouped)
        .navigationTitle(String(localized: "Title", table: "CalendarVisibility"))
    }
}
