import Foundation

extension UndoCoordinator {
    /// Moves the note to Recently Deleted; undo moves it back out of the trash.
    public func moveNoteToTrash(_ url: URL) async throws {
        guard let library else { return }
        await beginAction()
        let location = TrashedNoteLocation(original: url, trashed: try await library.moveToTrash(url))
        record(.reversible(
            .delete(.note),
            undo: { [library] in location.original = try await library.restore(location.trashed) },
            redo: { [library] in location.trashed = try await library.moveToTrash(location.original) }
        ))
    }
}

@MainActor
private final class TrashedNoteLocation {
    var original: URL
    var trashed: URL

    init(original: URL, trashed: URL) {
        self.original = original
        self.trashed = trashed
    }
}
