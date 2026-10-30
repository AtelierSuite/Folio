import Planner
import SwiftUI

/// Health access can change in the Settings app and HealthKit's database is unreadable while the
/// device is locked, neither of which wakes the observer query, so sleep is re-read on every return.
private struct SleepRefreshModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    let store: SleepStore

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active, store.isActive else { return }
                store.invalidate()
            }
    }
}

extension View {
    func refreshesSleep(_ store: SleepStore) -> some View {
        modifier(SleepRefreshModifier(store: store))
    }
}
