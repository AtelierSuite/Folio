import AppIntents
import Planner
import SwiftUI

extension View {
    /// Tells Siri which event, reminder or note "this" refers to while the view is on screen.
    func onScreenEntity(_ event: CalendarEvent) -> some View {
        appEntityIdentifier(EntityIdentifier(for: EventEntity.self, identifier: event.reference.storageKey))
    }

    func onScreenEntity(_ reminder: ReminderItem?) -> some View {
        appEntityIdentifier(reminder.map {
            EntityIdentifier(for: ReminderEntity.self, identifier: $0.reference.storageKey)
        })
    }

    func onScreenNote(at url: URL, in library: NotesLibrary) -> some View {
        appEntityIdentifier(library.store?.relativePath(of: url).map {
            EntityIdentifier(for: NoteEntity.self, identifier: $0)
        })
    }
}
