import Foundation

extension NotesLibrary {
    public func linkedNote(for event: CalendarEvent) -> LinkedNote? {
        linkedNotes.note(linkedTo: event.reference)
    }

    public func dailyNote(on date: Date) -> LinkedNote? {
        linkedNotes.dailyNote(on: date)
    }

    public func deepLink(for url: URL) -> URL? {
        store?.relativePath(of: url).flatMap(NoteDeepLink.url(forRelativePath:))
    }

    public func noteURL(forDeepLink deepLink: URL) -> URL? {
        NoteDeepLink.relativePath(from: deepLink).flatMap(noteURL(forEntityIdentifier:))
    }

    /// Returns the note already linked to `event` if there is one.
    public func createNote(for event: CalendarEvent) async throws -> URL {
        await waitForLinkedNotes()
        if let existing = linkedNote(for: event) {
            return existing.url
        }
        let template = LinkedNoteTemplate.eventNote(for: event)
        let note = try await createNote(titled: template.title, text: template.text)
        recordLinkedNote(note)
        return note.url
    }

    /// Returns the day's note already in the library if there is one.
    public func createDailyNote(on date: Date) async throws -> URL {
        await waitForLinkedNotes()
        if let existing = dailyNote(on: date) {
            return existing.url
        }
        let template = LinkedNoteTemplate.dailyNote(on: date)
        let note = try await requireStore().createNoteIfMissing(
            atRelativePath: DailyNoteNaming.relativePath(for: date), text: template.text
        )
        await refresh()
        recordLinkedNote(note)
        return note.url
    }

    func updateLinkedNotes() {
        linkingTask?.cancel()
        let files = notes
        let store = store
        let current = linkedNotes
        linkingTask = Task {
            let updated = if let store {
                await current.updated(with: files, in: store)
            } else {
                LinkedNoteIndex()
            }
            guard !Task.isCancelled, updated != linkedNotes else {
                return
            }
            linkedNotes = updated
        }
    }

    public func waitForLinkedNotes() async {
        while let task = linkingTask {
            await task.value
            if linkingTask == task {
                return
            }
        }
    }

    /// Makes a note created here findable right away, before the next index update reads it.
    private func recordLinkedNote(_ note: Note) {
        guard let store, let relativePath = store.relativePath(of: note.url) else {
            return
        }
        let file = NoteFile(url: note.url, relativePath: relativePath, modifiedDate: note.modifiedDate)
        linkedNotes.insert(LinkedNote(file: file, text: note.text))
    }
}
