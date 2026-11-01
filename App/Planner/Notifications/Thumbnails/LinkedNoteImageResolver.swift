import Foundation

/// Finds the first image in each event's linked note, reading a note again only once it has changed.
@MainActor
final class LinkedNoteImageResolver {
    private struct NoteVersion: Hashable {
        let url: URL
        let modifiedDate: Date
    }

    private let library: NotesLibrary
    private var firstImages: [NoteVersion: URL?] = [:]

    init(library: NotesLibrary) {
        self.library = library
    }

    func images(for events: [CalendarEvent]) async -> [CalendarItemReference: URL] {
        guard let store = library.store else { return [:] }
        var images: [CalendarItemReference: URL] = [:]
        var seenVersions = Set<NoteVersion>()
        for event in events {
            guard let note = library.linkedNote(for: event) else { continue }
            let version = NoteVersion(url: note.url, modifiedDate: note.file.modifiedDate)
            seenVersions.insert(version)
            if firstImages[version] == nil, let text = await store.readIfDownloaded(note.file)?.text {
                firstImages[version] = LinkedNoteImage.firstLocalImage(in: text, noteURL: note.url, store: store)
            }
            if let image = firstImages[version] ?? nil, LinkedNoteImage.isOnDevice(image) {
                images[event.reference] = image
            }
        }
        firstImages = firstImages.filter { seenVersions.contains($0.key) }
        return images
    }
}
