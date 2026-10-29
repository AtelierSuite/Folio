import Planner
import SwiftUI

struct EventLinkedNoteButton: View {
    @Environment(NotesLibrary.self) private var library
    @Environment(CalendarStore.self) private var calendarStore
    @Environment(AppRouter.self) private var router
    let event: CalendarEvent
    var onOpen: () -> Void = {}
    @State private var isWorking = false
    @State private var errorMessage: String?

    var body: some View {
        let isLinked = library.linkedNote(for: event) != nil
        Button {
            Task { await open() }
        } label: {
            Label(
                isLinked
                    ? String(localized: "Event.OpenNote", table: "LinkedNotes")
                    : String(localized: "Event.CreateNote", table: "LinkedNotes"),
                systemImage: isLinked ? "note.text" : "square.and.pencil"
            )
        }
        .disabled(library.store == nil || isWorking)
        .accessibilityIdentifier(isLinked ? "LinkedNote.Open" : "LinkedNote.Create")
        .notesErrorAlert(message: $errorMessage)
    }

    private func open() async {
        isWorking = true
        defer { isWorking = false }
        do {
            onOpen()
            try await LinkedNoteActions(library: library, calendarStore: calendarStore, router: router)
                .openNote(for: event)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
