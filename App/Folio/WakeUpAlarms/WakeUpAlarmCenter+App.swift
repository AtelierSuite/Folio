import Planner

extension WakeUpAlarmCenter {
    static func makeForApp() -> WakeUpAlarmCenter {
        let center = WakeUpAlarmCenter(capabilities: .current)
        #if os(iOS)
        center.performBackgroundWork = { work in
            let backgroundTask = BackgroundTask(name: "WakeUpAlarm.Replan")
            Task {
                await work()
                backgroundTask.end()
            }
        }
        #endif
        return center
    }
}
