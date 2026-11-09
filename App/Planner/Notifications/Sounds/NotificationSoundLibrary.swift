import Foundation

/// macOS doesn't play custom notification sounds from the app bundle, so they are
/// copied into the App Group's `Library/Sounds`, one of the folders it searches.
public struct NotificationSoundLibrary: Sendable {
    public let sourceBundleURL: URL
    public let destinationURL: URL

    public init(
        sourceBundleURL: URL = Bundle.main.resourceURL ?? Bundle.main.bundleURL,
        destinationURL: URL = AppGroup.containerURL.appending(path: "Library/Sounds", directoryHint: .isDirectory)
    ) {
        self.sourceBundleURL = sourceBundleURL
        self.destinationURL = destinationURL
    }

    @discardableResult
    public func install() -> [NotificationSound] {
        let fileManager = FileManager.default
        try? fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true)
        return NotificationSound.allCases.filter { sound in
            guard let fileName = sound.fileName else { return false }
            let source = sourceBundleURL.appending(path: fileName)
            let destination = destinationURL.appending(path: fileName)
            guard let sourceSize = Self.size(of: source) else { return false }
            if Self.size(of: destination) == sourceSize { return true }
            try? fileManager.removeItem(at: destination)
            return (try? fileManager.copyItem(at: source, to: destination)) != nil
        }
    }

    private static func size(of url: URL) -> Int? {
        try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize
    }
}
