import Planner
import SwiftUI

struct NoteEventLinkButton: View {
    @Environment(NotesLibrary.self) private var library
    let noteURL: URL
    @State private var isPicking = false

    var body: some View {
        let isLinked = library.eventLink(forNote: noteURL) != nil
        Button(
            String(localized: "LinkEvent.Title", table: "LinkedNotes"),
            systemImage: isLinked ? "calendar.badge.checkmark" : "calendar.badge.plus"
        ) {
            isPicking = true
        }
        .accessibilityIdentifier("Note.LinkEvent")
        .sheet(isPresented: $isPicking) {
            NoteEventPickerSheet(noteURL: noteURL, initialDate: initialDate)
        }
    }

    private var initialDate: Date {
        library.eventLink(forNote: noteURL).flatMap { DailyNoteNaming.date(forDayKey: $0.event.dayKey) } ?? .now
    }
}
