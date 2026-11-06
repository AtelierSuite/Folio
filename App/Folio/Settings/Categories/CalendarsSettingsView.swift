import SwiftUI

struct CalendarsSettingsView: View {
    var body: some View {
        Form {
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
