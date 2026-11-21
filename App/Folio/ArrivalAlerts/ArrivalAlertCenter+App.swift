import Planner
import WidgetKit

extension ArrivalAlertCenter {
    static func makeForApp() -> ArrivalAlertCenter {
        let center = ArrivalAlertCenter(capabilities: .current)
        center.onLeaveByChange = {
            WidgetCenter.shared.reloadTimelines(ofKind: leaveByWidgetKind)
            WidgetCenter.shared.reloadTimelines(ofKind: "DayLoadWidget")
        }
        #if os(iOS)
        center.performBackgroundWork = { work in
            let backgroundTask = BackgroundTask(name: "ArrivalAlert.Arrival")
            await work()
            backgroundTask.end()
        }
        #endif
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
            await CancellableSteps.run([
                { await arrivalAlerts?.replan() },
                { await leaveAlerts?.replan() },
                { await wakeUpAlarms?.replan() },
                { _ = await standaloneAlarms?.replan() },
                updateMedicationReminders
            ])
        }
    }
}
