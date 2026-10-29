import Foundation

@MainActor
final class NotesMetadataQuery {
    private let query = NSMetadataQuery()
    private let store: NoteFileStore
    private let onUpdate: @MainActor ([NoteFile]) -> Void
    private var observers: [NSObjectProtocol] = []

    init(store: NoteFileStore, onUpdate: @escaping @MainActor ([NoteFile]) -> Void) {
        self.store = store
        self.onUpdate = onUpdate
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(
            format: "%K LIKE[c] '*.md' OR %K LIKE[c] '*.markdown'", NSMetadataItemFSNameKey, NSMetadataItemFSNameKey
        )
        query.sortDescriptors = [NSSortDescriptor(key: NSMetadataItemFSContentChangeDateKey, ascending: false)]
        for name in [Notification.Name.NSMetadataQueryDidFinishGathering, .NSMetadataQueryDidUpdate] {
            observers.append(NotificationCenter.default.addObserver(
                forName: name, object: query, queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.publishResults()
                }
            })
        }
        query.start()
    }

    func stop() {
        query.stop()
        observers.forEach(NotificationCenter.default.removeObserver)
        observers.removeAll()
    }

    private func publishResults() {
        query.disableUpdates()
        defer { query.enableUpdates() }
        let files = query.results.compactMap { result in
            (result as? NSMetadataItem).flatMap(noteFile)
        }
        onUpdate(files)
    }

    private func noteFile(from item: NSMetadataItem) -> NoteFile? {
        guard let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL,
              store.isNoteURL(url),
              let relativePath = store.relativePath(of: url) else {
            return nil
        }
        let status = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String
        return NoteFile(
            url: url,
            relativePath: relativePath,
            modifiedDate: item.value(forAttribute: NSMetadataItemFSContentChangeDateKey) as? Date ?? .distantPast,
            isDownloaded: status == NSMetadataUbiquitousItemDownloadingStatusCurrent,
            hasUnresolvedConflicts: item.value(forAttribute: NSMetadataUbiquitousItemHasUnresolvedConflictsKey) as? Bool
                ?? false
        )
    }
}
