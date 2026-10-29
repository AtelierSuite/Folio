import Foundation

public actor NoteSpotlightIndexer {
    public static let defaultManifestURL = URL.applicationSupportDirectory
        .appending(path: "Spotlight", directoryHint: .isDirectory)
        .appending(path: "NotesIndex.json")

    private let index: any NoteSearchIndexing
    private let manifestURL: URL
    private var lastOperation: Task<Void, Never>?

    public init(index: any NoteSearchIndexing = SpotlightNoteIndex(), manifestURL: URL = defaultManifestURL) {
        self.index = index
        self.manifestURL = manifestURL
    }

    public func sync(_ files: [NoteFile], in store: NoteFileStore) async {
        await enqueue { indexer in
            await indexer.performSync(files, in: store)
        }
    }

    public func removeAll() async {
        await enqueue { indexer in
            await indexer.performRemoveAll()
        }
    }

    private func enqueue(_ operation: @escaping @Sendable (isolated NoteSpotlightIndexer) async -> Void) async {
        let previousOperation = lastOperation
        let task = Task {
            await previousOperation?.value
            await operation(self)
        }
        lastOperation = task
        await task.value
    }

    private func performSync(_ files: [NoteFile], in store: NoteFileStore) async {
        let rootPath = store.rootURL.path(percentEncoded: false)
        var manifest = NoteIndexManifest.load(from: manifestURL) ?? NoteIndexManifest()
        if manifest.rootPath != rootPath {
            guard (try? await index.deleteAllNotes()) != nil else {
                return
            }
            manifest = NoteIndexManifest(rootPath: rootPath)
            manifest.save(to: manifestURL)
        }
        let currentFiles = Dictionary(files.map { ($0.relativePath, $0) }, uniquingKeysWith: { first, _ in first })
        let removedIdentifiers = manifest.entries.keys.filter { currentFiles[$0] == nil }.sorted()
        if !removedIdentifiers.isEmpty, (try? await index.deleteNotes(identifiedBy: removedIdentifiers)) != nil {
            removedIdentifiers.forEach { manifest.entries[$0] = nil }
        }
        let changedFiles = currentFiles.values
            .filter { manifest.entries[$0.relativePath] != NoteIndexManifest.Entry($0) }
            .sorted { $0.relativePath < $1.relativePath }
        var entities: [NoteEntity] = []
        for file in changedFiles {
            entities.append(await store.entity(for: file))
        }
        if !entities.isEmpty, (try? await index.index(entities)) != nil {
            changedFiles.forEach { manifest.entries[$0.relativePath] = NoteIndexManifest.Entry($0) }
        }
        manifest.save(to: manifestURL)
    }

    private func performRemoveAll() async {
        if let manifest = NoteIndexManifest.load(from: manifestURL), manifest == NoteIndexManifest() {
            return
        }
        guard (try? await index.deleteAllNotes()) != nil else {
            return
        }
        NoteIndexManifest().save(to: manifestURL)
    }
}
