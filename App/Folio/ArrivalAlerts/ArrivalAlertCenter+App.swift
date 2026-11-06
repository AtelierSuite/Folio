import Planner
import WidgetKit

extension ArrivalAlertCenter {
    static func makeForApp() -> ArrivalAlertCenter {
        let center = ArrivalAlertCenter(capabilities: .current)
        center.onLeaveByChange = {
            WidgetCenter.shared.reloadTimelines(ofKind: "LeaveByWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "DayLoadWidget")
        }
        center.start()
        return center
    }
}

extension NotificationScheduler {
    func replansDependentAlerts(
        _ arrivalAlerts: ArrivalAlertCenter,
        _ leaveAlerts: LeaveAlertCenter,
        _ wakeUpAlarms: WakeUpAlarmCenter,
        _ standaloneAlarms: StandaloneAlarmCenter,
        _ medications: MedicationStore
    ) {
        let updateMedicationReminders: @MainActor () async -> Void = { [weak medications] in
            await medications?.updateReminders()
        }
        didReplan = { [weak arrivalAlerts, weak leaveAlerts, weak wakeUpAlarms, weak standaloneAlarms] in
            await arrivalAlerts?.replan()
            await leaveAlerts?.replan()
            await wakeUpAlarms?.replan()
            await standaloneAlarms?.replan()
            await updateMedicationReminders()
        }
    }
}
