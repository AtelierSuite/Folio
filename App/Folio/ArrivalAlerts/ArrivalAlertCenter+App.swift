import Planner

extension ArrivalAlertCenter {
    static func makeForApp() -> ArrivalAlertCenter {
        let center = ArrivalAlertCenter(capabilities: .current)
        center.start()
        return center
    }
}

extension NotificationScheduler {
    func replansDependentAlerts(
        _ arrivalAlerts: ArrivalAlertCenter,
        _ leaveAlerts: LeaveAlertCenter,
        _ wakeUpAlarms: WakeUpAlarmCenter,
        _ standaloneAlarms: StandaloneAlarmCenter
    ) {
        didReplan = { [weak arrivalAlerts, weak leaveAlerts, weak wakeUpAlarms, weak standaloneAlarms] in
            await arrivalAlerts?.replan()
            await leaveAlerts?.replan()
            await wakeUpAlarms?.replan()
            await standaloneAlarms?.replan()
        }
    }
}
