import SwiftUI

struct CalendarsSettingsView: View {
    var body: some View {
        Form {
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
