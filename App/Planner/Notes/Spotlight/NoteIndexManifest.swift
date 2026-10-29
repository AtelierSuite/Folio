import Foundation

/// What was last sent to the search index, so each sync only touches notes that changed.
struct NoteIndexManifest: Codable, Equatable {
    struct Entry: Codable, Equatable {
        let modifiedDate: Date
        let isDownloaded: Bool

        init(_ file: NoteFile) {
            modifiedDate = file.modifiedDate
            isDownloaded = file.isDownloaded
        }
    }

    var rootPath: String?
    var entries: [NoteEntity.ID: Entry] = [:]

    static func load(from url: URL) -> NoteIndexManifest? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(NoteIndexManifest.self, from: data)
    }

    func save(to url: URL) {
        guard let data = try? JSONEncoder().encode(self) else {
            return
        }
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? data.write(to: url, options: .atomic)
    }
}
