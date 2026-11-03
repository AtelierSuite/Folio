import SwiftUI

struct SettingsCategoryView: View {
    let category: SettingsCategory

    var body: some View {
        switch category {
        case .general: GeneralSettingsView()
        case .accounts: AccountsSettingsView()
        case .calendars: CalendarsSettingsView()
        case .workWeek: WorkWeekSettingsView()
        case .notes: NotesSettingsView()
        case .notifications: NotificationSettingsView()
        case .notificationStyles: NotificationStyleDefaultsView()
        case .notificationSounds: NotificationSoundsView()
        case .allDayAlerts: AllDayAlertTimesView()
        case .alarms: AlarmSettingsView()
        case .sleep: SleepSettingsView()
        case .weather: WeatherSettingsView()
        case .search: SearchSettingsView()
        case .privacy: PrivacySettingsView()
        #if DEBUG
        case .debug: DebugSettingsView()
        #endif
        }
    }
}
