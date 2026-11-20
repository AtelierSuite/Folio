import Planner
import SwiftUI

extension View {
    /// Brings running countdowns in line with the calendar at launch, on every change and
    /// when the app comes back, so a moved event is followed and a deleted one ends. Finished
    /// countdowns end on the way to the background, as the finish timer stops once suspended.
    func reconcilesCountdowns(_ countdowns: EventCountdownManager, with store: CalendarStore) -> some View {
        modifier(CountdownReconciliationModifier(countdowns: countdowns, store: store))
    }
}

private struct CountdownReconciliationModifier: ViewModifier {
    let countdowns: EventCountdownManager
    let store: CalendarStore
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .task(id: store.contentRevision) {
                await countdowns.reconcile()
            }
            .onChange(of: scenePhase) { _, phase in
                switch phase {
                case .active: Task { await countdowns.reconcile() }
                case .background: Task { await countdowns.endFinished() }
                default: break
                }
            }
    }
}
