import SwiftUI

struct RemindersSettingsView: View {
    var body: some View {
        Form {
            ReminderSettingsSection()
        }
        .settingsCategoryStyle(.reminders)
    }
}
