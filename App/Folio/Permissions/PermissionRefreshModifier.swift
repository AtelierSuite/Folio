import Planner
import SwiftUI

struct PermissionRefreshModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    let center: PermissionCenter

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase, initial: true) { _, phase in
                guard phase == .active else { return }
                Task {
                    await center.refresh()
                }
            }
    }
}

extension View {
    func refreshesPermissions(of center: PermissionCenter) -> some View {
        modifier(PermissionRefreshModifier(center: center))
    }
}
