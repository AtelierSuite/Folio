import Planner
import SwiftUI

/// Alerts show the first image in an event's linked note, so editing a linked note replans them.
struct LinkedNoteImageReplanTrigger: ViewModifier {
    static let debounce: Duration = .seconds(2)

    let scheduler: NotificationScheduler
    let library: NotesLibrary

    func body(content: Content) -> some View {
        content
            .task(id: library.linkedNotes) {
                try? await Task.sleep(for: Self.debounce)
                guard !Task.isCancelled else { return }
                await scheduler.replan()
            }
    }
}

extension View {
    func replansNotificationsOnLinkedNoteChanges(
        _ scheduler: NotificationScheduler,
        library: NotesLibrary
    ) -> some View {
        modifier(LinkedNoteImageReplanTrigger(scheduler: scheduler, library: library))
    }
}
