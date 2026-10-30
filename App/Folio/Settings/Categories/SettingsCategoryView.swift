import SwiftUI

struct SettingsCategoryView: View {
    let category: SettingsCategory

    var body: some View {
        switch category {
        case .general: GeneralSettingsView()
        case .calendars: CalendarsSettingsView()
        case .notes: NotesSettingsView()
        case .notifications: NotificationSettingsView()
        case .sleep: SleepSettingsView()
        case .searchAndPrivacy: SearchAndPrivacySettingsView()
        #if DEBUG
        case .debug: DebugSettingsView()
        #endif
        }
    }
}
