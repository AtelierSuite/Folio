import SwiftUI

struct CalendarsSettingsView: View {
    var body: some View {
        Form {
            Section {
                NavigationLink(String(localized: "WorkWeek.Title", table: "Week")) { WorkWeekSettingsView() }
                    .accessibilityIdentifier("WorkWeekLink")
            }
            ReminderSettingsSection()
            InvitationSettingsSection()
            TravelTimeSettingsSection()
            SecondaryTimeZoneSection()
            AlternateCalendarSection()
            DayHighlightSection()
        }
        .settingsCategoryStyle(.calendars)
    }
}
