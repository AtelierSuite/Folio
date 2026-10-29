import Foundation

extension NotesLibrary {
    static let suggestedEntityLimit = 20

    public func noteEntities(for identifiers: [NoteEntity.ID]) async -> [NoteEntity] {
        await start()
        guard let store else {
            return []
        }
        let filesByIdentifier = Dictionary(notes.map { ($0.relativePath, $0) }, uniquingKeysWith: { first, _ in first })
        var entities: [NoteEntity] = []
        for identifier in identifiers {
            let file = filesByIdentifier[identifier] ?? store.file(atRelativePath: identifier)
            if let file {
                entities.append(await store.entity(for: file))
            }
        }
        return entities
    }

    public func noteEntities(matching string: String) async -> [NoteEntity] {
        await start()
        return notes
            .filter { $0.title.localizedStandardContains(string) }
            .map(NoteEntity.init(placeholderFor:))
    }

    public func suggestedNoteEntities() async -> [NoteEntity] {
        await start()
        return notes.prefix(Self.suggestedEntityLimit).map(NoteEntity.init(placeholderFor:))
    }

    public func noteURL(forEntityIdentifier identifier: NoteEntity.ID) -> URL? {
        store?.file(atRelativePath: identifier)?.url
    }
}

extension NoteFileStore {
    func file(atRelativePath relativePath: String) -> NoteFile? {
        let url = rootURL.appending(path: relativePath)
        guard isNoteURL(url), FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else {
            return nil
        }
        return NoteFile(url: url, relativePath: relativePath, modifiedDate: modificationDate(of: url))
    }
}
