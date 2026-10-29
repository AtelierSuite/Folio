import Planner
import SwiftUI
#if os(iOS)
import UIKit
#endif

extension View {
    /// Connects the window's `UndoManager` to the undo coordinator and writes staged deletes
    /// when the app goes to the background.
    func connectsUndo() -> some View {
        modifier(UndoSceneConnection())
    }
}

private struct UndoSceneConnection: ViewModifier {
    @Environment(UndoCoordinator.self) private var coordinator
    @Environment(\.undoManager) private var undoManager
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .onAppear(perform: connect)
            .onChange(of: undoManager.map(ObjectIdentifier.init)) { connect() }
            .onChange(of: scenePhase) { _, phase in
                switch phase {
                case .active: connect()
                case .background: commitPending()
                default: break
                }
            }
            .onReceive(AssistiveTechnology.changes) { _ in
                coordinator.isAssistiveTechnologyRunning = AssistiveTechnology.isRunning
            }
            .alert(
                String(localized: "Failure.Title", table: "Undo"),
                isPresented: Binding(get: { coordinator.failure != nil }, set: { if !$0 { coordinator.failure = nil } })
            ) {
                Button(String(localized: "OK", table: "Undo"), role: .cancel) {}
            } message: {
                Text(coordinator.failure?.localizedDescription ?? "")
            }
    }

    private func connect() {
        coordinator.undoManager = undoManager
        coordinator.isAssistiveTechnologyRunning = AssistiveTechnology.isRunning
    }

    private func commitPending() {
        guard coordinator.hasPendingCommit else { return }
        #if os(iOS)
        let backgroundTask = UIApplication.shared.beginBackgroundTask()
        Task {
            await coordinator.commitPending()
            UIApplication.shared.endBackgroundTask(backgroundTask)
        }
        #else
        Task {
            await coordinator.commitPending()
        }
        #endif
    }
}
