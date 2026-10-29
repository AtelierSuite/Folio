import Planner

extension ArrivalAlertCenter {
    static func makeForApp(following scheduler: NotificationScheduler) -> ArrivalAlertCenter {
        let center = ArrivalAlertCenter(capabilities: .current)
        scheduler.didReplan = { [weak center] in
            await center?.replan()
        }
        center.start()
        return center
    }
}
