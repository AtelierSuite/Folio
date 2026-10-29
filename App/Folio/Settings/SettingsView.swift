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
            TimelineSettingsSection()
            MonthSettingsSection()
            WeatherSettingsSection()
            SleepSettingsSection()
            PermissionsSettingsSection()
            SearchSettingsSection()
            LinkedNotesSettingsSection()
            Section {
                LabeledContent(
                    String(localized: "About.Version", table: "Settings"),
                    value: Bundle.main.versionDescription
                )
            }
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
