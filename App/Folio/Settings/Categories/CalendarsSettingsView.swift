import Planner
import SwiftUI

struct CalendarsSettingsView: View {
    var body: some View {
        Form {
            PermissionPromptSection(
                kind: .location,
                message: String(localized: "Prompt.TravelTime", table: "Permissions"),
                asksOnToggle: true
            )
            EventLocationsSettingsSection()
            ReminderSettingsSection()
            InvitationSettingsSection()
            DuplicateDetectionSection()
            TravelTimeSettingsSection()
            SecondaryTimeZoneSection()
            AlternateCalendarSection()
            DayHighlightSection()
        }
        .settingsCategoryStyle(.calendars)
    }
}
