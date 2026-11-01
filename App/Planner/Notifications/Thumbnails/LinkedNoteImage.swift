import Foundation

enum LinkedNoteImage {
    /// Only images stored with the notes count, since an alert can't fetch one from the web.
    static func firstLocalImage(in text: String, noteURL: URL, store: NoteFileStore) -> URL? {
        MarkdownImageReference.references(in: text).lazy.compactMap { reference -> URL? in
            guard URL(string: reference.source)?.scheme == nil else { return nil }
            let url = store.resolveLink(reference.source, from: noteURL)
            return store.relativePath(of: url) == nil ? nil : url
        }.first
    }

    /// An image still in iCloud would have to be downloaded while alerts are being scheduled, so it's skipped.
    static func isOnDevice(_ url: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else { return false }
        let values = try? url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
        guard let status = values?.ubiquitousItemDownloadingStatus else { return true }
        return status == .current
    }
}
