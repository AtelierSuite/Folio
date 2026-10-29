import Planner
import SwiftUI

struct DailyNoteCard: View {
    @Environment(NotesLibrary.self) private var library
    @Environment(CalendarStore.self) private var calendarStore
    @Environment(AppRouter.self) private var router
    let date: Date
    @State private var isWorking = false
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let note = library.dailyNote(on: date) {
                DailyNotePreview(note: note) {
                    Task { await open() }
                }
            } else {
                Button {
                    Task { await open() }
                } label: {
                    Label(String(localized: "Daily.Create", table: "LinkedNotes"), systemImage: "square.and.pencil")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderless)
                .accessibilityIdentifier("DailyNote.Create")
            }
        }
        .disabled(isWorking)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .notesErrorAlert(message: $errorMessage)
    }

    private func open() async {
        isWorking = true
        defer { isWorking = false }
        do {
            try await LinkedNoteActions(library: library, calendarStore: calendarStore, router: router)
                .openDailyNote(on: date)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
