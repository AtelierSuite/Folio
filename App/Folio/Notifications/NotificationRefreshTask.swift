#if os(iOS)
import BackgroundTasks
import Planner
import SwiftUI

nonisolated enum NotificationRefreshTask {
    static let identifier = "com.tsubuzaki.Folio.notifications.refresh"
    static let interval: TimeInterval = 3600

    static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: interval)
        try? BGTaskScheduler.shared.submit(request)
    }
}

extension Scene {
    func notificationRefreshTask(_ scheduler: NotificationScheduler) -> some Scene {
        backgroundTask(.appRefresh(NotificationRefreshTask.identifier)) {
            NotificationRefreshTask.schedule()
            await scheduler.replan()
        }
    }
}
#else
import Planner
import SwiftUI

extension Scene {
    func notificationRefreshTask(_ scheduler: NotificationScheduler) -> some Scene {
        self
    }
}
#endif
