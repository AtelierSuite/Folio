import SwiftUI

/// The chosen maps app can be removed while Folio is in the background.
private struct DirectionsAppRefreshModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase, initial: true) { _, phase in
                guard phase == .active else { return }
                DirectionsAppInstallation.refresh()
            }
    }
}

extension View {
    func refreshesDirectionsApp() -> some View {
        modifier(DirectionsAppRefreshModifier())
    }
}
