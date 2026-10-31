import Foundation

extension NotesLibrary {
    public func linkedNote(for event: CalendarEvent) -> LinkedNote? {
        linkedNotes.note(linkedTo: event.reference)
    }

    public func dailyNote(on date: Date) -> LinkedNote? {
        linkedNotes.dailyNote(on: date)
    }

    public func eventLink(forNote url: URL) -> NoteLink? {
        store?.relativePath(of: url).flatMap { noteLinks[$0] }
    }

    public func deepLink(for url: URL) -> URL? {
        store?.relativePath(of: url).flatMap(NoteDeepLink.url(forRelativePath:))
    }

    public func noteURL(forDeepLink deepLink: URL) -> URL? {
        NoteDeepLink.relativePath(from: deepLink).flatMap(noteURL(forEntityIdentifier:))
    }

    /// Returns the note already linked to `event` if there is one.
    public func createNote(for event: CalendarEvent) async throws -> URL {
        if let existing = linkedNote(for: event) {
            return existing.url
        }
        let template = LinkedNoteTemplate.eventNote(for: event)
        let note = try await createNote(titled: template.title, text: template.text)
        link(note.url, to: event)
        return note.url
    }

    /// Returns the day's note already in the library if there is one.
    public func createDailyNote(on date: Date) async throws -> URL {
        if let existing = dailyNote(on: date) {
            return existing.url
        }
        let template = LinkedNoteTemplate.dailyNote(on: date)
        let note = try await requireStore().createNoteIfMissing(
            atRelativePath: DailyNoteNaming.relativePath(for: date), text: template.text
        )
        await refresh()
        return note.url
    }

    public func link(_ url: URL, to event: CalendarEvent) {
        guard let location = indexLocation, let path = store?.relativePath(of: url) else { return }
        index.link(notePath: path, in: location, to: NoteLinkEvent(event: event))
        updateLinkedNotes()
    }

    public func unlink(_ url: URL) {
        guard let location = indexLocation, let path = store?.relativePath(of: url) else { return }
        removeLinks(index.unlink(notePath: path, in: location))
    }

    /// The event is gone, so there is no URL to clean up on it.
    func unlinkEvent(_ eventKey: String) {
        guard let location = indexLocation else { return }
        index.unlink(eventKey: eventKey, in: location)
        updateLinkedNotes()
    }

    func moveLinks(from oldURL: URL, to newURL: URL) {
        guard let location = indexLocation, let store,
              let oldPath = store.relativePath(of: oldURL), let newPath = store.relativePath(of: newURL) else {
            return
        }
        index.moveLinks(from: oldPath, to: newPath, in: location)
        updateLinkedNotes()
    }

    func removeLinks(_ links: [NoteLink]) {
        updateLinkedNotes()
        if !links.isEmpty {
            onLinksRemoved?(links)
        }
    }

    /// Links come from the index and are matched to the listed notes; nothing is read from the notes themselves.
    func updateLinkedNotes() {
        guard let location = indexLocation else {
            noteLinks = [:]
            linkedNotes = LinkedNoteIndex()
            return
        }
        let links = Dictionary(index.links(in: location).map { ($0.notePath, $0) }, uniquingKeysWith: { $1 })
        let files = Dictionary(notes.map { ($0.relativePath, $0) }, uniquingKeysWith: { first, _ in first })
        let linked = links.values.compactMap { link in
            files[link.notePath].map { LinkedNote(file: $0, eventKey: link.event.eventKey, dayKey: link.event.dayKey) }
        }
        let daily = notes.filter { DailyNoteNaming.dayKey(ofRelativePath: $0.relativePath) != nil }
            .map { LinkedNote(file: $0) }
        noteLinks = links
        linkedNotes = LinkedNoteIndex(notes: daily + linked)
    }
}

extension NotesLibrary {
    /// The start of a note's text, read from its file when shown; downloading it first if needed.
    public func preview(of url: URL) async -> String {
        guard let note = try? await read(url) else { return "" }
        return String(MarkdownDocument(parsing: note.text).plainText.prefix(LinkedNote.previewLength))
    }
}
