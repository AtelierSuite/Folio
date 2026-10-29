import Foundation

extension NotesLibrary {
    /// Switches where notes are stored. Notes are moved out of On My Device, but copied out of
    /// iCloud Drive or a chosen folder, since other devices or apps may still rely on them there.
    @discardableResult
    public func switchMode(
        to newMode: NotesStorageMode,
        folderURL: URL? = nil,
        migratingNotes: Bool
    ) async throws -> NotesMigrationSummary {
        let newFolder = try folderURL.map { url in
            let folder = SecurityScopedFolder(url: url)
            return (folder: folder, bookmark: try folder.bookmarkData())
        }
        let destinationFolder = newMode == .customFolder ? newFolder?.folder ?? customFolder : nil
        guard let destinationURL = await rootURL(for: newMode, folder: destinationFolder) else {
            throw newMode == .iCloudDrive ? NotesStorageError.iCloudUnavailable : NotesStorageError.folderNotChosen
        }
        var summary = NotesMigrationSummary()
        if migratingNotes, let store {
            isMigrating = true
            defer { isMigrating = false }
            summary = try await store.migrate(
                to: NoteFileStore(rootURL: destinationURL),
                removingSource: !mode.keepsSourceAfterMigration
            )
        }
        if let newFolder, newMode == .customFolder {
            settings.folderBookmark = newFolder.bookmark
        }
        settings.mode = newMode
        customFolder = destinationFolder
        mode = newMode
        await activateCurrentMode()
        return summary
    }
}
