import Planner
import SwiftUI

struct SettingsCategoryView: View {
    let category: SettingsCategory

    var body: some View {
        switch category {
        case .general: GeneralSettingsView()
        case .accounts: AccountsSettingsView()
        case .calendars: CalendarsSettingsView()
        case .reminders: RemindersSettingsView()
        case .workWeek: WorkWeekSettingsView()
        case .flexTime: FlexTimeSettingsView()
        case .notes: NotesSettingsView()
        case .notifications: NotificationSettingsView()
        case .eventNotifications: CalendarNotificationSettingsView(kind: .event)
        case .reminderNotifications: CalendarNotificationSettingsView(kind: .reminder)
        case .wakeUpAlarm: WakeUpAlarmSettingsView()
        case .travel: TravelSettingsView()
        case .countdowns: CountdownSettingsView()
        case .focusLevel: FocusLevelSettingsView()
        case .workouts: WorkoutSettingsView()
        case .sleep: SleepSettingsView()
        case .medications: MedicationSettingsView()
        case .weather: WeatherSettingsView()
        case .search: SearchSettingsView()
        case .advanced: AdvancedSettingsView()
        #if DEBUG
        case .debug: DebugSettingsView()
        #endif
        }
    }
}
