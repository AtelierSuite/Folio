import Planner
import SwiftUI

struct NoteSessionView: View {
    @Bindable var session: NoteEditingSession
    let onRename: (URL) -> Void
    let onTrash: (URL) -> Void

    var body: some View {
        content
            .navigationTitle(session.title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItemGroup {
                    Button(String(localized: "Action.Rename", table: "Notes"), systemImage: "pencil") {
                        onRename(session.url)
                    }
                    Button(String(localized: "Action.Delete", table: "Notes"), systemImage: "trash") {
                        onTrash(session.url)
                    }
                }
            }
            .alert(
                String(localized: "Conflict.Title", table: "Notes"),
                isPresented: isShowingConflict
            ) {
                Button(String(localized: "Action.OK", table: "Notes")) {}
            } message: {
                Text(String(localized: "Conflict.Message", table: "Notes"))
            }
    }

    @ViewBuilder
    private var content: some View {
        switch session.state {
        case .loading:
            ProgressView(String(localized: "Detail.Loading", table: "Notes"))
        case .ready:
            NoteEditorView(text: $session.text)
        case .failed(let message):
            ContentUnavailableView(
                String(localized: "Detail.LoadFailed.Title", table: "Notes"),
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
        }
    }

    private var isShowingConflict: Binding<Bool> {
        Binding(
            get: { session.conflictedCopyURL != nil },
            set: { isPresented in
                if !isPresented {
                    session.conflictedCopyURL = nil
                }
            }
        )
    }
}
