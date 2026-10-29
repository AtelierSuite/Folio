import Planner
import SwiftUI

extension View {
    /// `handler` returns whether it showed the destination, which then stops being pending.
    func handlesAppDestinations(_ handler: @escaping (AppDestination) -> Bool) -> some View {
        modifier(AppDestinationHandler(handler: handler))
    }
}

private struct AppDestinationHandler: ViewModifier {
    @Environment(AppRouter.self) private var router
    let handler: (AppDestination) -> Bool

    func body(content: Content) -> some View {
        content
            .onChange(of: router.pendingDestination, initial: true) { _, destination in
                if let destination, handler(destination) {
                    router.pendingDestination = nil
                }
            }
    }
}
