import Foundation
import Testing
@testable import Planner

struct NoteFileStoreMigrationTests {
    @Test func movesNotesAssetsAndTrashToTheNewLocation() async throws {
        let directory = try TemporaryDirectory()
        let deviceRoot = try directory.makeSubdirectory("Device")
        let folderRoot = try directory.makeSubdirectory("Folder")
        try directory.write("Note", to: "Note.md", in: deviceRoot)
        try directory.write("Nested", to: "Sub/Nested.md", in: deviceRoot)
        try directory.write("PNG", to: "assets/photo.png", in: deviceRoot)
        try directory.write("Gone", to: ".trash/Gone.md", in: deviceRoot)
        try directory.write("Junk", to: ".DS_Store", in: deviceRoot)
        let source = NoteFileStore(rootURL: deviceRoot)
        let destination = NoteFileStore(rootURL: folderRoot)

        let summary = try await source.migrate(to: destination, removingSource: true)

        #expect(summary.copiedFileCount == 4)
        #expect(Set(try await destination.notes().map(\.relativePath)) == ["Note.md", "Sub/Nested.md"])
        #expect(try await destination.trashedNotes().map(\.title) == ["Gone"])
        #expect(FileManager.default.fileExists(atPath: folderRoot.appending(path: "assets/photo.png").path()))
        #expect(try await source.notes().isEmpty)
        #expect(try await source.trashedNotes().isEmpty)
        #expect(try FileManager.default.contentsOfDirectory(atPath: deviceRoot.path()) == [".DS_Store"])
    }

    @Test func copyingKeepsTheSourceAndNeverOverwritesExistingFiles() async throws {
        let directory = try TemporaryDirectory()
        let cloudRoot = try directory.makeSubdirectory("Cloud")
        let deviceRoot = try directory.makeSubdirectory("Device")
        try directory.write("Same", to: "Same.md", in: cloudRoot)
        try directory.write("Same", to: "Same.md", in: deviceRoot)
        try directory.write("Cloud version", to: "Clash.md", in: cloudRoot)
        try directory.write("Device version", to: "Clash.md", in: deviceRoot)
        let source = NoteFileStore(rootURL: cloudRoot)
        let destination = NoteFileStore(rootURL: deviceRoot)

        let summary = try await source.migrate(to: destination, removingSource: false)

        #expect(summary.copiedFileCount == 1)
        #expect(summary.skippedDuplicateCount == 1)
        #expect(summary.renamedFileCount == 1)
        #expect(try await destination.read(deviceRoot.appending(path: "Clash.md")).text == "Device version")
        #expect(try await destination.read(deviceRoot.appending(path: "Clash 2.md")).text == "Cloud version")
        #expect(try await source.notes().count == 2)
    }
}
