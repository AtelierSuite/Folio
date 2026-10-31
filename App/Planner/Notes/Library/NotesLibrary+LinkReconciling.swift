import Foundation

extension NotesLibrary {
    static let missingNoteGrace: TimeInterval = 24 * 60 * 60

    /// Drops the links of notes deleted outside Folio. A note has to be missing from a complete listing for a
    /// whole day first, so a listing that is still syncing or a moment without the folder never loses links.
    func reconcileLinks(now: Date = .now) {
        guard hasCompleteListing, let location = indexLocation else { return }
        let trashPrefix = "\(NoteFileStore.trashFolderName)/"
        let present = Set(notes.map(\.relativePath)).union(trashedNotes.map { trashPrefix + $0.relativePath })
        let prefix = "note:\(location)/"
        var missingKeys = Set<String>()
        var removed: [NoteLink] = []
        for link in index.links(in: location) where !present.contains(link.notePath) {
            let key = prefix + link.notePath
            missingKeys.insert(key)
            if now.timeIntervalSince(index.markMissing(key, at: now)) >= Self.missingNoteGrace {
                removed += index.unlink(notePath: link.notePath, in: location)
            }
        }
        index.clearMissing(withPrefix: prefix, except: missingKeys)
        if !removed.isEmpty {
            removeLinks(removed)
        }
    }

    /// Links of the notes in `trashURL`, removed when the trash is emptied or a note in it deleted for good.
    func unlinkTrashed(at trashedURL: URL?) {
        guard let location = indexLocation, let store else { return }
        let trashPrefix = "\(NoteFileStore.trashFolderName)/"
        let paths = if let trashedURL {
            store.relativePath(of: trashedURL).map { [$0] } ?? []
        } else {
            index.links(in: location).map(\.notePath).filter { $0.hasPrefix(trashPrefix) }
        }
        removeLinks(paths.flatMap { index.unlink(notePath: $0, in: location) })
    }
}
