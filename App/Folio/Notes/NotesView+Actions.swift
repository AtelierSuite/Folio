import Planner
import SwiftUI

extension NotesView {
    var sidebarSelection: Binding<NotesSidebarItem?> {
        Binding(
            get: {
                if isShowingRecentlyDeleted {
                    return .recentlyDeleted
                }
                return selection.map(NotesSidebarItem.note)
            },
            set: { item in
                switch item {
                case .recentlyDeleted:
                    selection = nil
                    isShowingRecentlyDeleted = true
                case .note(let url):
                    isShowingRecentlyDeleted = false
                    selection = url
                case nil:
                    isShowingRecentlyDeleted = false
                    selection = nil
                }
            }
        )
    }

    func openNote(at url: URL?) async {
        guard session?.url != url else {
            return
        }
        if let session, await !session.flush() {
            unsavedNoteDestination = UnsavedNoteDestination(url: url)
            selection = session.url
            return
        }
        guard let url else {
            session = nil
            return
        }
        let newSession = NoteEditingSession(url: url, library: library, focusesEditorOnOpen: url == createdNoteURL)
        session = newSession
        OpenNoteSessions.shared.track(newSession)
        await newSession.load()
    }

    func discardUnsavedNote(_ destination: UnsavedNoteDestination) {
        session?.close()
        session = nil
        selection = destination.url
    }

    func createNote() {
        Task {
            do {
                let note = try await library.createNote(
                    titled: String(localized: "NewNote.DefaultTitle", table: "Notes")
                )
                createdNoteURL = note.url
                selection = note.url
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func openDailyNote(on date: Date) {
        Task {
            await library.start()
            do {
                selection = try await library.createDailyNote(on: date)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func rename(_ url: URL, to title: String) {
        Task {
            do {
                if session?.url == url {
                    await session?.flush()
                }
                let newURL = try await library.rename(url, to: title)
                if session?.url == url {
                    session?.didMove(to: newURL)
                }
                if selection == url {
                    selection = newURL
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func moveToTrash(_ url: URL) {
        Task {
            do {
                if session?.url == url {
                    session?.close()
                    session = nil
                }
                if selection == url {
                    selection = nil
                }
                try await undoCoordinator.moveNoteToTrash(url)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
