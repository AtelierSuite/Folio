import Foundation

public struct NotificationSoundLibrary: Sendable {
    public let sourceBundleURL: URL
    public let destinationURL: URL

    public init(sourceBundleURL: URL = Bundle.main.resourceURL ?? Bundle.main.bundleURL, destinationURL: URL) {
        self.sourceBundleURL = sourceBundleURL
        self.destinationURL = destinationURL
    }

    public static var bundledSounds: [NotificationSound] {
        NotificationSound.allCases.filter { $0.fileName != nil }
    }

    @discardableResult
    public func install() -> [NotificationSound] {
        let fileManager = FileManager.default
        try? fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true)
        return Self.bundledSounds.filter { sound in
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
