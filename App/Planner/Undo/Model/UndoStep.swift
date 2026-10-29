import Foundation

/// One undoable or redoable change. Performing it runs its synchronous part right away and
/// returns the step that reverses it, so `UndoManager` can register that inverse before the
/// asynchronous EventKit or file work finishes.
@MainActor
struct UndoStep {
    struct Outcome {
        let inverse: UndoStep
        let work: (@MainActor () async throws -> Void)?
    }

    let id = UUID()
    let action: UndoAction
    let target: UndoTarget
    let isRedo: Bool
    let perform: @MainActor () -> Outcome

    static func reversible(
        _ action: UndoAction,
        target: UndoTarget = UndoTarget(),
        isRedo: Bool = false,
        undo: @escaping @MainActor () async throws -> Void,
        redo: @escaping @MainActor () async throws -> Void
    ) -> UndoStep {
        UndoStep(action: action, target: target, isRedo: isRedo) {
            Outcome(
                inverse: reversible(action, target: target, isRedo: !isRedo, undo: redo, redo: undo),
                work: undo
            )
        }
    }
}

/// `UndoManager` removes registrations by target, so each step that can expire gets its own.
final class UndoTarget {}

extension UndoManager.UserInfoKey {
    static let undoStepIdentifier = UndoManager.UserInfoKey(rawValue: "Folio.UndoStepIdentifier")
}
