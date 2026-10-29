import Planner
import SwiftUI

extension View {
    /// Shows the undo toast over this view while it's the frontmost toast host.
    func undoToastHost() -> some View {
        modifier(UndoToastHost())
    }
}

private struct UndoToastHost: ViewModifier {
    @Environment(UndoCoordinator.self) private var coordinator
    @Environment(UndoToastHosts.self) private var hosts
    @State private var identifier = UUID()

    private var visibleToast: UndoToast? {
        hosts.topHostIdentifier == identifier ? coordinator.toast : nil
    }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let toast = visibleToast {
                    UndoToastView(toast: toast, onUndo: coordinator.undoToast)
                        .padding(.bottom, 72)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .id(toast.id)
                }
            }
            .animation(.snappy, value: visibleToast)
            .onAppear { hosts.add(identifier) }
            .onDisappear { hosts.remove(identifier) }
            .onChange(of: visibleToast) { _, toast in
                guard let toast else { return }
                AccessibilityNotification.Announcement(String(
                    format: String(localized: "Toast.Announcement", table: "Undo"), toast.action.toastTitle
                )).post()
            }
    }
}
