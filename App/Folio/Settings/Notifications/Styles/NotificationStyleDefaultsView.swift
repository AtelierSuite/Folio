import Planner
import SwiftUI

struct NotificationStyleDefaultsView: View {
    @Environment(CalendarStore.self) private var store
    @Environment(PermissionCenter.self) private var permissionCenter
    @Environment(\.platformCapabilities) private var capabilities

    var body: some View {
        Form {
            if store.eventCalendars.isEmpty && store.reminderLists.isEmpty {
                Text(String(localized: "Defaults.Empty", table: "NotificationStyles"))
                    .foregroundStyle(.secondary)
            }
            if permissionCenter.status(of: .alarms) == .denied {
                NotificationAlarmDeniedSection()
            }
            CalendarAccountSections(
                calendars: store.eventCalendars,
                kindTitle: String(localized: "Defaults.Calendars", table: "NotificationStyles"),
                footer: footer
            ) { NotificationStyleCalendarRow(calendar: $0) }
            CalendarAccountSections(
                calendars: store.reminderLists,
                kindTitle: String(localized: "Defaults.ReminderLists", table: "NotificationStyles")
            ) { NotificationStyleCalendarRow(calendar: $0) }
        }
        .formStyle(.grouped)
        .navigationTitle(String(localized: "Defaults.Title", table: "NotificationStyles"))
        .task {
            await permissionCenter.refresh(.alarms)
        }
    }

    private var footer: String {
        capabilities.supports(.alarms)
            ? String(localized: "Defaults.Footer.Alarms", table: "NotificationStyles")
            : String(localized: "Defaults.Footer", table: "NotificationStyles")
    }
}
