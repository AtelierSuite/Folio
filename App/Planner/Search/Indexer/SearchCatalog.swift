import Foundation

actor SearchCatalog {
    private var index = SearchIndex()
    private var noteVersions: [String: NoteVersion] = [:]

    var count: Int { index.count }

    func replaceCalendarItems(with documents: [SearchDocument]) {
        let currentIDs = Set(documents.map(\.id))
        let staleIDs = index.documentIDs(of: .event)
            .union(index.documentIDs(of: .reminder))
            .subtracting(currentIDs)
        index.apply(upserting: documents, removing: staleIDs)
    }

    func notesNeedingIndexing(in files: [NoteFile]) -> [NoteFile] {
        files.filter { noteVersions[SearchDocument.noteID(for: $0.url)] != NoteVersion($0) }
    }

    func replaceNotes(listed files: [NoteFile], indexing documents: [SearchDocument]) {
        let listedVersions = Dictionary(
            files.map { (SearchDocument.noteID(for: $0.url), NoteVersion($0)) }, uniquingKeysWith: { first, _ in first }
        )
        let staleIDs = Set(noteVersions.keys).subtracting(listedVersions.keys)
        index.apply(upserting: documents, removing: staleIDs)
        for id in staleIDs {
            noteVersions[id] = nil
        }
        for document in documents {
            noteVersions[document.id] = listedVersions[document.id]
        }
    }

    func search(_ query: SearchQuery) -> [SearchDocument] {
        index.search(query)
    }
}

private struct NoteVersion: Hashable {
    let modifiedDate: Date
    let isDownloaded: Bool

    init(_ file: NoteFile) {
        modifiedDate = file.modifiedDate
        isDownloaded = file.isDownloaded
    }
}
