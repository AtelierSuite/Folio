import Planner
import SwiftUI

struct WakeUpCalendarsView: View {
    @Environment(CalendarStore.self) private var store

    var body: some View {
        Form {
            if store.eventCalendars.isEmpty {
                Text(String(localized: "Calendars.Empty", table: "WakeUpAlarms"))
                    .foregroundStyle(.secondary)
            } else {
                CalendarAccountSections(
                    calendars: store.eventCalendars,
                    footer: String(localized: "Calendars.Footer", table: "WakeUpAlarms")
                ) { calendar in
                    WakeUpCalendarRow(calendar: calendar)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(String(localized: "Calendars", table: "WakeUpAlarms"))
        .toolbarTitleDisplayMode(.inline)
    }
}
