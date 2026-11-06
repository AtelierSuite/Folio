import Planner
import SwiftUI
import WidgetKit

extension View {
    /// Keeps the Event Notes widget's digests in step with the notes and the calendar.
    func publishesEventNoteDigests(from library: NotesLibrary, events store: CalendarStore) -> some View {
        modifier(EventNoteDigestPublishing(library: library, store: store))
    }
}

private struct EventNoteDigestPublishing: ViewModifier {
    private struct Trigger: Equatable {
        let revision: Int
        let notes: LinkedNoteIndex
    }

    let library: NotesLibrary
    let store: CalendarStore

    func body(content: Content) -> some View {
        content.task(id: Trigger(revision: store.contentRevision, notes: library.linkedNotes)) {
            let interval = DateInterval(
                start: .now,
                duration: Double(EventNoteDigest.lookAheadDays) * 86_400
            )
            let events = await store.events(in: interval)
            if await EventNoteDigestPublisher().publish(events: events, library: library) {
                WidgetCenter.shared.reloadTimelines(ofKind: "EventNotesWidget")
            }
        }
    }
}
