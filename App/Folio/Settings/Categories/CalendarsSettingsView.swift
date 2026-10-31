import SwiftUI

struct CalendarsSettingsView: View {
    var body: some View {
        Form {
            Section {
                NavigationLink(String(localized: "Title", table: "CalendarVisibility")) {
                    CalendarVisibilityView()
                }
                .accessibilityIdentifier("CalendarVisibilityLink")
                NavigationLink(String(localized: "WorkWeek.Title", table: "Week")) { WorkWeekSettingsView() }
                    .accessibilityIdentifier("WorkWeekLink")
            }
            ReminderSettingsSection()
            InvitationSettingsSection()
            SecondaryTimeZoneSection()
            AlternateCalendarSection()
        }
        .settingsCategoryStyle(.calendars)
    }
}
