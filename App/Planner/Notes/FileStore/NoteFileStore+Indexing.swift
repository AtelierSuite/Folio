import Foundation

extension NoteFileStore {
    /// Reads a note already on the device without downloading it, as indexing must never pull notes down.
    @concurrent
    func readIfDownloaded(_ file: NoteFile) async -> Note? {
        guard file.isDownloaded else { return nil }
        return try? FileCoordination.read(at: file.url) { coordinatedURL in
            try loadNote(at: coordinatedURL, reportedURL: file.url)
        }
    }

    @concurrent
    func assetFileNames() async -> [String] {
        let path = assetsURL.path(percentEncoded: false)
        let names = (try? FileManager.default.contentsOfDirectory(atPath: path)) ?? []
        return names.filter { name in
            var isDirectory: ObjCBool = false
            FileManager.default.fileExists(atPath: assetsURL.appending(path: name).path(percentEncoded: false),
                                           isDirectory: &isDirectory)
            return !name.hasPrefix(".") && !isDirectory.boolValue
        }
    }

    @concurrent
    func deleteAsset(named name: String) async throws {
        try FileCoordination.delete(at: assetsURL.appending(path: name))
    }
}
