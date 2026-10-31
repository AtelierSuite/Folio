import Planner
import SwiftUI

struct NoteEventLinkButton: View {
    @Bindable var session: NoteEditingSession
    @State private var isPicking = false

    var body: some View {
        let isLinked = NoteEventLink.eventKey(in: session.text) != nil
        Button(
            String(localized: "LinkEvent.Title", table: "LinkedNotes"),
            systemImage: isLinked ? "calendar.badge.checkmark" : "calendar.badge.plus"
        ) {
            isPicking = true
        }
        .accessibilityIdentifier("Note.LinkEvent")
        .sheet(isPresented: $isPicking) {
            NoteEventPickerSheet(text: $session.text, noteURL: session.url)
        }
    }
}
