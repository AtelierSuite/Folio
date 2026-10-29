import Planner
import SwiftUI

extension View {
    /// Brings running countdowns in line with the calendar at launch, on every change and
    /// when the app comes back, so a moved event is followed and a deleted one ends.
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
                guard phase == .active else { return }
                Task { await countdowns.reconcile() }
            }
    }
}
