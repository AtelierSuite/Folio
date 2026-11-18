import Planner
import SwiftUI

struct BirthdaySettingsView: View {
    @Environment(CalendarStore.self) private var store

    var body: some View {
        Form {
            PermissionPromptSection(
                kind: .calendar,
                message: String(localized: "Prompt", table: "Birthdays")
            )
            if let calendar = store.birthdayCalendar {
                BirthdayVisibilitySection(calendar: calendar)
                BirthdayAlertsSection(calendar: calendar)
            } else {
                Text(String(localized: "Empty", table: "Birthdays"))
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("BirthdaysForm")
        .settingsCategoryStyle(.birthdays)
    }
}
