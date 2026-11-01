import Foundation

extension NotificationScheduler {
    public func attachesLinkedNoteImages(from library: NotesLibrary) {
        guard capabilities.supports(.notificationThumbnails) else { return }
        let resolver = LinkedNoteImageResolver(library: library)
        eventImages = { events in
            await resolver.images(for: events)
        }
    }
}
