import Planner
import SwiftUI

extension NotesView {
    func openNote(at url: URL?) async {
        guard session?.url != url else {
            return
        }
        await session?.flush()
        guard let url else {
            session = nil
            return
        }
        let newSession = NoteEditingSession(url: url, library: library)
        session = newSession
        await newSession.load()
    }

    func createNote() {
        Task {
            do {
                let note = try await library.createNote(
                    titled: String(localized: "NewNote.DefaultTitle", table: "Notes")
                )
                selection = note.url
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
                try await library.moveToTrash(url)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
