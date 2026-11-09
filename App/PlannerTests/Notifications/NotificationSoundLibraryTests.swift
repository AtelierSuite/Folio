import Foundation
import Testing
@testable import Planner

struct NotificationSoundLibraryTests {
    private let root = FileManager.default.temporaryDirectory
        .appending(path: "NotificationSoundLibraryTests-\(UUID().uuidString)", directoryHint: .isDirectory)

    private func makeLibrary(bundledFiles: [String: Data]) throws -> NotificationSoundLibrary {
        let bundle = root.appending(path: "Bundle", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: bundle, withIntermediateDirectories: true)
        for (fileName, data) in bundledFiles {
            try data.write(to: bundle.appending(path: fileName))
        }
        return NotificationSoundLibrary(
            sourceBundleURL: bundle,
            destinationURL: root.appending(path: "Library/Sounds", directoryHint: .isDirectory)
        )
    }

    @Test func copiesBundledSoundsIntoTheSoundsFolder() throws {
        let library = try makeLibrary(bundledFiles: ["Calendar-Furin.caf": Data([1, 2, 3])])
        defer { try? FileManager.default.removeItem(at: root) }

        #expect(library.install() == [.furin])
        let copied = try Data(contentsOf: library.destinationURL.appending(path: "Calendar-Furin.caf"))
        #expect(copied == Data([1, 2, 3]))
    }

    @Test func replacesAnOutdatedCopy() throws {
        let library = try makeLibrary(bundledFiles: ["Reminder-Yuki.caf": Data([4, 5, 6, 7])])
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: library.destinationURL, withIntermediateDirectories: true)
        try Data([9]).write(to: library.destinationURL.appending(path: "Reminder-Yuki.caf"))

        #expect(library.install() == [.yuki])
        let copied = try Data(contentsOf: library.destinationURL.appending(path: "Reminder-Yuki.caf"))
        #expect(copied == Data([4, 5, 6, 7]))
    }
}
