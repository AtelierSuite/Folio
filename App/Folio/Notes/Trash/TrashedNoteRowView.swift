import Planner
import SwiftUI

struct TrashedNoteRowView: View {
    let file: NoteFile
    let onRestore: () -> Void
    let onDelete: () -> Void
    @State private var isShowingActions = false

    var body: some View {
        Button {
            isShowingActions = true
        } label: {
            NoteRowView(file: file)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .confirmationDialog(file.title, isPresented: $isShowingActions, titleVisibility: .visible) {
            actions
        }
        .contextMenu {
            actions
        }
        .swipeActions(edge: .leading) {
            restoreButton
                .tint(.blue)
        }
        .swipeActions(edge: .trailing) {
            Button(
                String(localized: "Action.DeletePermanently", table: "Notes"),
                systemImage: "trash",
                role: .destructive,
                action: onDelete
            )
        }
    }

    @ViewBuilder
    private var actions: some View {
        restoreButton
        Button(
            String(localized: "Action.DeletePermanently", table: "Notes"),
            systemImage: "trash",
            role: .destructive,
            action: onDelete
        )
    }

    private var restoreButton: some View {
        Button(
            String(localized: "Action.Restore", table: "Notes"),
            systemImage: "arrow.uturn.backward",
            action: onRestore
        )
    }
}
