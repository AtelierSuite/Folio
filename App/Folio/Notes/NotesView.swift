import Planner
import SwiftUI

struct NotesView: View {
    @Environment(NotesLibrary.self) var library
    @Environment(\.scenePhase) private var scenePhase
    @State var selection: URL?
    @State var session: NoteEditingSession?
    @State var renamingURL: URL?
    @State var createdNoteURL: URL?
    @State var isShowingRecentlyDeleted = false
    @State var errorMessage: String?

    var body: some View {
        NavigationSplitView {
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
        .onChange(of: selection) { _, newSelection in
            Task {
                await openNote(at: newSelection)
            }
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
