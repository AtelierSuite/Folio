import Planner
import SwiftUI

struct NotesView: View {
    @Environment(NotesLibrary.self) var library
    @Environment(UndoCoordinator.self) var undoCoordinator
    @Environment(\.scenePhase) private var scenePhase
    @State var selection: URL?
    @State var session: NoteEditingSession?
    @State var renamingURL: URL?
    @State var createdNoteURL: URL?
    @State var isShowingRecentlyDeleted = false
    @State var errorMessage: String?

    var body: some View {
        SidebarSplitView {
            NotesSidebarView(
                selection: sidebarSelection,
                onCreate: createNote,
                onRename: { renamingURL = $0 },
                onTrash: moveToTrash
            )
        } detail: {
            if isShowingRecentlyDeleted {
                RecentlyDeletedView()
            } else {
                NoteDetailView(session: session, onRename: { renamingURL = $0 }, onTrash: moveToTrash)
            }
        }
        .renameNoteAlert(url: $renamingURL, onRename: rename)
        .notesErrorAlert(message: $errorMessage)
        .task {
            await library.start()
        }
        .handlesAppDestinations { destination in
            switch destination {
            case .note(let url):
                selection = url
                return true
            case .newNote:
                createNote()
                return true
            default:
                return false
            }
        }
        .onChange(of: selection) { _, newSelection in
            if newSelection != nil {
                isShowingRecentlyDeleted = false
            }
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
