import Foundation

/// A change that EventKit can't reverse (a delete or a series split), so it's only shown
/// in the app until the undo toast expires and is written when it's committed.
@MainActor
struct DeferredChange {
    let action: UndoAction
    let stage: @MainActor () -> UUID
    let unstage: @MainActor (UUID) -> Void
    let commit: @MainActor () async throws -> Void
    /// Work to run on undo and redo besides unstaging and restaging, such as a conversion's new item.
    var revert: (@MainActor () async throws -> Void)?
    var reapply: (@MainActor () async throws -> Void)?
}

@MainActor
struct PendingCommit {
    let stepIdentifier: UUID
    let stagedIdentifier: UUID
    let target: UndoTarget
    let change: DeferredChange
}
