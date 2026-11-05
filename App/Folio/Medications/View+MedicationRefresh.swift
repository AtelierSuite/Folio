import Planner
import SwiftUI

/// Medication sharing can change in the Health app and Health is unreadable while the device is
/// locked, neither of which wakes the observer query, so doses are re-read on every return.
private struct MedicationRefreshModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    let store: MedicationStore

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active, store.isActive else { return }
                Task { await store.refresh() }
            }
    }
}

extension View {
    func refreshesMedications(_ store: MedicationStore) -> some View {
        modifier(MedicationRefreshModifier(store: store))
    }
}
