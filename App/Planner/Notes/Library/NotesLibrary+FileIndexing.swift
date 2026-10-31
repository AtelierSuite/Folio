import Foundation

extension NotesLibrary {
    static let unusedAssetGrace: TimeInterval = 7 * 24 * 60 * 60
    static let fileIndexingDelay = Duration.seconds(2)

    private struct ListedNote {
        let path: String
        let file: NoteFile
        let isTrashed: Bool
    }

    func scheduleFileIndexing() {
        fileIndexingTask?.cancel()
        fileIndexingTask = Task {
            try? await Task.sleep(for: Self.fileIndexingDelay)
            guard !Task.isCancelled else { return }
            await indexFiles()
        }
    }

    /// Reads only notes that are on the device and changed since this device last read them, moving any old front
    /// matter into the index, then removes images no note has mentioned for `unusedAssetGrace`.
    func indexFiles(now: Date = .now) async {
        guard hasCompleteListing, status == .ready, !isMigrating, let location = indexLocation, let store else {
            return
        }
        let trashPrefix = "\(NoteFileStore.trashFolderName)/"
        let listed = notes.map { ListedNote(path: $0.relativePath, file: $0, isTrashed: false) }
            + trashedNotes.map { ListedNote(path: trashPrefix + $0.relativePath, file: $0, isTrashed: true) }
        let states = index.fileStates(in: location)
        for note in listed {
            if let state = states[note.path], state.modifiedDate == note.file.modifiedDate,
               state.isTrashed == note.isTrashed {
                continue
            }
            guard !Task.isCancelled, var read = await store.readIfDownloaded(note.file) else { continue }
            if !note.isTrashed, let migrated = await migrateFrontMatter(of: read, at: note.path, in: location) {
                read = migrated
            }
            index.recordFile(note.path, in: location, state: NoteFileState(
                modifiedDate: read.modifiedDate,
                isTrashed: note.isTrashed,
                referencedNames: MarkdownFileNames.names(in: read.text).sorted()
            ))
        }
        index.keepFiles(Set(listed.map(\.path)), in: location)
        let isComplete = listed.allSatisfy { note in
            note.file.isDownloaded && index.fileStates(in: location)[note.path] != nil
        }
        if isComplete {
            await removeUnusedAssets(in: store, location: location, now: now)
        }
    }

    /// Notes written by earlier versions keep links in front matter. The link moves into the index first, and the
    /// front matter is only removed from the note once the index holds it.
    private func migrateFrontMatter(of note: Note, at path: String, in location: String) async -> Note? {
        let file = MarkdownNoteFile(contents: note.text)
        guard !file.frontMatter.isEmpty, let store else { return nil }
        if let eventKey = file.frontMatter.event, noteLinks[path] == nil {
            let occurrence = CalendarItemReference(storageKey: eventKey)?.occurrenceDate
            let dayKey = (file.frontMatter.date ?? occurrence).map { DailyNoteNaming.dayKey(for: $0) } ?? ""
            let event = NoteLinkEvent(eventKey: eventKey, calendarIdentifier: "", title: "", dayKey: dayKey)
            index.link(notePath: path, in: location, to: event, at: note.modifiedDate)
            guard index.links(in: location).contains(where: { $0.notePath == path }) else { return nil }
            updateLinkedNotes()
        }
        guard case .saved(let saved) = try? await store.save(file.body, over: note) else { return nil }
        return saved
    }

    private func removeUnusedAssets(in store: NoteFileStore, location: String, now: Date) async {
        let used = Set(index.fileStates(in: location).values.flatMap(\.referencedNames))
        let prefix = "asset:\(location)/"
        var unusedKeys = Set<String>()
        for name in await store.assetFileNames() where !used.contains(name.lowercased()) {
            let key = prefix + name
            unusedKeys.insert(key)
            if now.timeIntervalSince(index.markMissing(key, at: now)) >= Self.unusedAssetGrace,
               (try? await store.deleteAsset(named: name)) != nil {
                unusedKeys.remove(key)
            }
        }
        index.clearMissing(withPrefix: prefix, except: unusedKeys)
    }
}
