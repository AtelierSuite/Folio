import Foundation

final class TemporaryDirectory {
    let url: URL

    init() throws {
        url = FileManager.default.temporaryDirectory
            .appending(path: "PlannerTests-\(UUID().uuidString)", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    deinit {
        try? FileManager.default.removeItem(at: url)
    }

    func makeSubdirectory(_ name: String) throws -> URL {
        let subdirectory = url.appending(path: name, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: subdirectory, withIntermediateDirectories: true)
        return subdirectory
    }

    func write(_ text: String, to relativePath: String, in rootURL: URL? = nil) throws {
        let fileURL = (rootURL ?? url).appending(path: relativePath)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        try Data(text.utf8).write(to: fileURL)
    }
}
