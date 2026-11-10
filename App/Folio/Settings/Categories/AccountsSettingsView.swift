import Planner
import SwiftUI

struct AccountsSettingsView: View {
    @Environment(CalendarStore.self) private var store

    var body: some View {
        Form {
            if store.eventCalendars.isEmpty && store.reminderLists.isEmpty {
                Text(String(localized: "Empty", table: "CalendarVisibility"))
                    .foregroundStyle(.secondary)
            }
            DefaultCalendarsSection()
            CalendarAccountSections(
                calendars: store.eventCalendars,
                lists: store.reminderLists
            ) { calendar in
                CalendarVisibilityRow(calendar: calendar)
            }
        }
        .accessibilityIdentifier("AccountsForm")
        .settingsCategoryStyle(.accounts)
    }
}
