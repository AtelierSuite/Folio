import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            NotesStorageSection()
            Section {
                NavigationLink(String(localized: "Title", table: "Notifications")) {
                    NotificationSettingsView()
                }
                .accessibilityIdentifier("NotificationSettingsLink")
                NavigationLink(String(localized: "Title", table: "CalendarVisibility")) {
                    CalendarVisibilityView()
                }
                .accessibilityIdentifier("CalendarVisibilityLink")
                NavigationLink(String(localized: "WorkWeek.Title", table: "Week")) { WorkWeekSettingsView() }
                    .accessibilityIdentifier("WorkWeekLink")
            }
            EventTapSettingsSection()
            TimelineSettingsSection()
            DragSettingsSection()
            MonthSettingsSection()
            WeatherSettingsSection()
            SleepSettingsSection()
            SecondaryTimeZoneSection()
            PermissionsSettingsSection()
            SearchSettingsSection()
            LinkedNotesSettingsSection()
            ReminderSettingsSection()
            InvitationSettingsSection()
            #if DEBUG
            TimelineDebugSettingsSection()
            MarkdownDebugSection()
            #endif
        }
        .formStyle(.grouped)
        .navigationTitle(String(localized: "Title", table: "Settings"))
        #if os(macOS)
        .frame(minWidth: 480, minHeight: 320)
        #endif
    }
}
