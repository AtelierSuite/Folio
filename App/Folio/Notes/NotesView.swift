import Planner
import SwiftUI

struct NotesView: View {
    @Environment(NotesLibrary.self) var library
    @Environment(NoteNavigator.self) private var navigator
    @Environment(\.scenePhase) private var scenePhase
    @State var selection: URL?
    @State var session: NoteEditingSession?
    @State var renamingURL: URL?
    @State var createdNoteURL: URL?
    @State var isShowingRecentlyDeleted = false
    @State var errorMessage: String?

    var body: some View {
        NotesSplitView {
            NotesSidebarView(
                selection: $selection,
                onCreate: createNote,
                onRename: { renamingURL = $0 },
                onTrash: moveToTrash,
                onShowRecentlyDeleted: { isShowingRecentlyDeleted = true }
            )
        } detail: {
            NoteDetailView(session: session, onRename: { renamingURL = $0 }, onTrash: moveToTrash)
        }
        .renameNoteAlert(url: $renamingURL, onRename: rename)
        .notesErrorAlert(message: $errorMessage)
        .sheet(isPresented: $isShowingRecentlyDeleted) {
            RecentlyDeletedView()
        }
        .task {
            await library.start()
        }
        .handlesAppDestinations { destination in
            guard case .note(let url) = destination else { return false }
            selection = url
            return true
        }
        .onChange(of: selection) { _, newSelection in
            Task {
                await openNote(at: newSelection)
            }
        }
        .onChange(of: navigator.requestedNoteURL, initial: true) { _, url in
            guard let url else {
                return
            }
            selection = url
            navigator.requestedNoteURL = nil
        }
        .onChange(of: library.notes) { _, notes in
            session?.reloadIfChangedElsewhere(in: notes)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task {
                    await library.refresh()
                }
            } else {
                Task {
                    await session?.flush()
                }
            }
        }
    }
}
