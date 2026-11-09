import Planner
#if os(iOS)
import UIKit
#endif

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

#if os(iOS)
@MainActor
private final class BackgroundTask {
    private var identifier = UIBackgroundTaskIdentifier.invalid

    init(name: String) {
        identifier = UIApplication.shared.beginBackgroundTask(withName: name) { [weak self] in
            self?.end()
        }
    }

    func end() {
        guard identifier != .invalid else { return }
        UIApplication.shared.endBackgroundTask(identifier)
        identifier = .invalid
    }
}
#endif
