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
}
