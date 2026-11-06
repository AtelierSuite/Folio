import Foundation

/// Reads the notes linked to upcoming events and leaves their digests where the widget can find them.
@MainActor
public struct EventNoteDigestPublisher {
    private let store: EventNoteDigestStore

    public init(store: EventNoteDigestStore = EventNoteDigestStore()) {
        self.store = store
    }

    /// Returns whether the digests changed. A note that isn't downloaded keeps the digest it already had.
    @discardableResult
    public func publish(events: [CalendarEvent], library: NotesLibrary) async -> Bool {
        let previous = store.digests
        var digests: [String: EventNoteDigest] = [:]
        for event in events {
            guard let linked = library.linkedNote(for: event) else { continue }
            let key = event.reference.storageKey
            if let note = await library.store?.readIfDownloaded(linked.file) {
                digests[key] = EventNoteDigest(
                    notePath: linked.file.relativePath, title: linked.title, text: note.text
                )
            } else {
                digests[key] = previous[key]
            }
        }
        guard digests != previous else { return false }
        store.store(digests)
        return true
    }
}
