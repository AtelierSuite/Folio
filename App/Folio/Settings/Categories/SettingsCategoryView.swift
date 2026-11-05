import Planner
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
        case .eventNotifications: CalendarNotificationSettingsView(kind: .event)
        case .reminderNotifications: CalendarNotificationSettingsView(kind: .reminder)
        case .alarms: AlarmSettingsView()
        case .countdowns: CountdownSettingsView()
        case .sleep: SleepSettingsView()
        case .medications: MedicationSettingsView()
        case .weather: WeatherSettingsView()
        case .search: SearchSettingsView()
        case .privacy: PrivacySettingsView()
        #if DEBUG
        case .debug: DebugSettingsView()
        #endif
        }
    }
}
