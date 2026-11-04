#if DEBUG
import Foundation

extension NotesLibrary {
    /// Writes the sample notes over any an earlier run left, dated so the list keeps their order.
    public func seedScreenshotNotes(_ samples: [ScreenshotSamples.SampleNote], now: Date = .now) async throws {
        await start()
        guard let rootURL = store?.rootURL else { return }
        let fileManager = FileManager.default
        for title in ScreenshotSamples.allNoteTitles {
            try? fileManager.removeItem(at: Self.screenshotNoteURL(titled: title, in: rootURL))
        }
        for sample in samples {
            let url = Self.screenshotNoteURL(titled: sample.title, in: rootURL)
            try sample.text.write(to: url, atomically: true, encoding: .utf8)
            let modified = now.addingTimeInterval(-TimeInterval(sample.minutesAgo * 60))
            try fileManager.setAttributes([.modificationDate: modified], ofItemAtPath: url.path(percentEncoded: false))
        }
        await refresh()
    }

    public func screenshotNoteURL(titled title: String) -> URL? {
        store.map { Self.screenshotNoteURL(titled: title, in: $0.rootURL) }
    }

    private static func screenshotNoteURL(titled title: String, in rootURL: URL) -> URL {
        rootURL.appending(path: "\(title).\(NoteFileNaming.noteExtension)")
    }
}
#endif
