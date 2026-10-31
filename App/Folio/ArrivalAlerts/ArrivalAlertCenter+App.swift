import Planner

extension ArrivalAlertCenter {
    static func makeForApp() -> ArrivalAlertCenter {
        let center = ArrivalAlertCenter(capabilities: .current)
        center.start()
        return center
    }
}

extension NotificationScheduler {
    func replansLocationAlerts(_ arrivalAlerts: ArrivalAlertCenter, _ leaveAlerts: LeaveAlertCenter) {
        didReplan = { [weak arrivalAlerts, weak leaveAlerts] in
            await arrivalAlerts?.replan()
            await leaveAlerts?.replan()
        }
    }
}
