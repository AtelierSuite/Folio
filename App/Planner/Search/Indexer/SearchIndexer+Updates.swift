import Foundation

extension SearchIndexer {
    /// EventKit doesn't say what changed, so the whole range is fetched again and only
    /// the events and reminders that differ from the index are re-tokenized.
    public func reindexCalendar() async {
        guard isActive else { return }
        await perform { [source, catalog, indexedInterval] in
            async let events = source.events(in: indexedInterval)
            async let reminders = source.reminders(completedIn: indexedInterval)
            let documents = await events.map(SearchDocument.init(event:))
                + reminders.map(SearchDocument.init(reminder:))
            await catalog.replaceCalendarItems(with: documents)
        }
    }

    /// Only notes that are new or modified since they were last indexed are read again.
    public func updateNotes(_ files: [NoteFile]) async {
        guard isActive else { return }
        await perform { [catalog] in
            let changedFiles = await catalog.notesNeedingIndexing(in: files)
            let documents = await Self.readDocuments(for: changedFiles)
            await catalog.replaceNotes(listed: files, indexing: documents)
        }
    }

    @concurrent
    private static func readDocuments(for files: [NoteFile]) async -> [SearchDocument] {
        files.map { file in
            let text = file.isDownloaded
                ? try? FileCoordination.read(at: file.url) { try String(contentsOf: $0, encoding: .utf8) }
                : nil
            return SearchDocument(note: file, text: text)
        }
    }
}
