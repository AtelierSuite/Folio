import Foundation

/// Digests saved as JSON in the App Group for the Event Notes widget, keyed by event storage key.
public struct EventNoteDigestStore: Sendable {
    public let fileURL: URL

    public init(fileURL: URL = EventNoteDigestStore.defaultFileURL) {
        self.fileURL = fileURL
    }

    public static var defaultFileURL: URL {
        AppGroup.containerURL.appending(path: "Library/Caches/Widgets/EventNotes.json", directoryHint: .notDirectory)
    }

    public var digests: [String: EventNoteDigest] {
        guard let data = try? Data(contentsOf: fileURL) else { return [:] }
        return (try? JSONDecoder().decode([String: EventNoteDigest].self, from: data)) ?? [:]
    }

    public func store(_ digests: [String: EventNoteDigest]) {
        guard let data = try? JSONEncoder().encode(digests) else { return }
        try? FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        try? data.write(to: fileURL, options: .atomic)
    }
}
