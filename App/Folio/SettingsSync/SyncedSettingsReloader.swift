import Planner
import SwiftUI

/// Stores keep their own copy of settings, so they re-read them when iCloud brings in new values.
struct SyncedSettingsReloader: ViewModifier {
    let settingsSync: SettingsCloudSync

    @Environment(CalendarStore.self) private var calendarStore
    @Environment(WorkWeekPreferences.self) private var workWeekPreferences
    @Environment(NotificationScheduler.self) private var notificationScheduler
    @Environment(LeaveAlertCenter.self) private var leaveAlerts
    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms
    @Environment(SearchIndexer.self) private var searchIndexer
    @Environment(WeatherStore.self) private var weatherStore
    @Environment(TravelTimeStore.self) private var travelTimeStore
    @Environment(FlexTimeCenter.self) private var flexTime

    func body(content: Content) -> some View {
        content
            .onAppear {
                settingsSync.didApplyCloudChanges = reloadAction()
            }
    }

    /// Captures the stores themselves, since the closure outlives this view's environment.
    private func reloadAction() -> @MainActor () -> Void {
        let calendarStore = calendarStore
        let workWeekPreferences = workWeekPreferences
        let notificationScheduler = notificationScheduler
        let leaveAlerts = leaveAlerts
        let wakeUpAlarms = wakeUpAlarms
        let searchIndexer = searchIndexer
        let weatherStore = weatherStore
        let travelTimeStore = travelTimeStore
        let flexTime = flexTime
        return {
            NotificationCategoryRegistry.register()
            calendarStore.reloadDisplaySettings()
            workWeekPreferences.reloadWorkdays()
            weatherStore.reloadSettings()
            travelTimeStore.reloadSettings()
            Task {
                await flexTime.reloadSettings()
                await notificationScheduler.reloadSettings()
                await leaveAlerts.reloadSettings()
                await wakeUpAlarms.reloadSettings()
                await searchIndexer.reloadRange()
            }
        }
    }
}

extension View {
    func reloadsSyncedSettings(from settingsSync: SettingsCloudSync) -> some View {
        modifier(SyncedSettingsReloader(settingsSync: settingsSync))
    }
}
