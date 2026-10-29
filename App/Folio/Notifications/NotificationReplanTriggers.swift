import Planner
import SwiftUI

struct NotificationReplanTriggers: ViewModifier {
    static let periodicInterval: Duration = .seconds(15 * 60)

    let scheduler: NotificationScheduler
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .task {
                scheduler.startObservingChanges()
                scheduler.startPeriodicReplanning(every: Self.periodicInterval)
                await scheduler.replan()
            }
            .onChange(of: scenePhase) { _, phase in
                handle(phase)
            }
    }

    private func handle(_ phase: ScenePhase) {
        switch phase {
        case .active:
            Task { await scheduler.replan() }
        case .background:
            #if os(iOS)
            NotificationRefreshTask.schedule()
            #endif
        default:
            break
        }
    }
}

extension View {
    func notificationReplanTriggers(_ scheduler: NotificationScheduler) -> some View {
        modifier(NotificationReplanTriggers(scheduler: scheduler))
    }
}
