import Foundation
import Observation

/// Shows the undo toast and keeps `UndoManager` in step with it. Deletes and series splits
/// are only staged (hidden or previewed) and are written when the toast expires, the app
/// goes to the background or the next action starts, so quitting within that window loses
/// nothing. Simple edits are saved at once and undone by saving the old values back.
@MainActor
@Observable
public final class UndoCoordinator {
    public static let toastDuration: Duration = .seconds(3)
    public static let assistiveToastDuration: Duration = .seconds(10)

    public private(set) var toast: UndoToast?
    public var failure: (any Error)?
    /// Keeps the toast up longer while VoiceOver or Switch Control is running.
    public var isAssistiveTechnologyRunning = false

    @ObservationIgnored public weak var undoManager: UndoManager?
    @ObservationIgnored let store: CalendarStore
    @ObservationIgnored let library: NotesLibrary?
    @ObservationIgnored let toastDurations: (standard: Duration, assistive: Duration)
    @ObservationIgnored var pending: PendingCommit?
    @ObservationIgnored private var toastStep: UndoStep?
    @ObservationIgnored private var expiry: Task<Void, Never>?
    @ObservationIgnored private var lastWork: Task<Void, Never>?

    public init(
        store: CalendarStore,
        library: NotesLibrary? = nil,
        toastDuration: Duration = UndoCoordinator.toastDuration,
        assistiveToastDuration: Duration = UndoCoordinator.assistiveToastDuration
    ) {
        self.store = store
        self.library = library
        toastDurations = (toastDuration, assistiveToastDuration)
    }

    public var hasPendingCommit: Bool {
        pending != nil
    }

    /// Writes the staged delete or edit now, as when the app goes to the background.
    public func commitPending() async {
        detachPending()
        await settle()
    }

    /// Undoes the change the toast is showing.
    public func undoToast() {
        guard let step = toastStep else { return }
        if let undoManager, undoManager.canUndo,
           undoManager.undoActionUserInfoValue(forKey: .undoStepIdentifier) as? UUID == step.id {
            undoManager.undo()
        } else {
            undoManager?.removeAllActions(withTarget: step.target)
            perform(step, registeringInverse: false)
        }
    }

    public func dismissToast() {
        expiry?.cancel()
        expiry = nil
        toast = nil
        toastStep = nil
    }

    public func expireToast() {
        guard let step = toastStep else { return }
        dismissToast()
        if pending?.stepIdentifier == step.id {
            detachPending()
        }
    }

    /// Waits for queued commits, undos and redos to finish.
    public func settle() async {
        await lastWork?.value
    }

    /// Starts a new action: the staged change from the previous one is written first.
    func beginAction() async {
        await commitPending()
    }

    func record(_ step: UndoStep) {
        register(step)
        show(step)
    }

    func stage(_ change: DeferredChange) -> UndoStep {
        detachPending()
        let stagedIdentifier = change.stage()
        let target = UndoTarget()
        let step = UndoStep(action: change.action, target: target, isRedo: false) { [unowned self] in
            if let pending, pending.target === target {
                self.pending = nil
                pending.change.unstage(pending.stagedIdentifier)
            }
            return UndoStep.Outcome(inverse: restaging(change), work: nil)
        }
        pending = PendingCommit(
            stepIdentifier: step.id, stagedIdentifier: stagedIdentifier, target: target, change: change
        )
        return step
    }

    func enqueue(_ work: @escaping @MainActor () async throws -> Void) {
        let previous = lastWork
        lastWork = Task { [weak self] in
            await previous?.value
            do {
                try await work()
            } catch {
                self?.failure = error
            }
        }
    }

    private func restaging(_ change: DeferredChange) -> UndoStep {
        UndoStep(action: change.action, target: UndoTarget(), isRedo: true) { [unowned self] in
            UndoStep.Outcome(inverse: stage(change), work: nil)
        }
    }

    private func perform(_ step: UndoStep, registeringInverse: Bool) {
        if toastStep?.id == step.id {
            dismissToast()
        }
        let outcome = step.perform()
        if registeringInverse {
            register(outcome.inverse)
        }
        if step.isRedo {
            show(outcome.inverse)
        }
        if let work = outcome.work {
            enqueue(work)
        }
    }

    private func register(_ step: UndoStep) {
        guard let undoManager else { return }
        undoManager.beginUndoGrouping()
        undoManager.registerUndo(withTarget: step.target) { [weak self] _ in
            self?.perform(step, registeringInverse: true)
        }
        undoManager.setActionName(step.action.actionName)
        undoManager.setActionUserInfoValue(step.id, forKey: .undoStepIdentifier)
        undoManager.endUndoGrouping()
    }

    private func show(_ step: UndoStep) {
        expiry?.cancel()
        toastStep = step
        toast = UndoToast(id: step.id, action: step.action)
        let duration = isAssistiveTechnologyRunning ? toastDurations.assistive : toastDurations.standard
        expiry = Task { [weak self] in
            try? await Task.sleep(for: duration)
            guard !Task.isCancelled else { return }
            self?.expireToast()
        }
    }

    private func detachPending() {
        guard let pending else { return }
        self.pending = nil
        undoManager?.removeAllActions(withTarget: pending.target)
        if toastStep?.id == pending.stepIdentifier {
            dismissToast()
        }
        enqueue {
            defer { pending.change.unstage(pending.stagedIdentifier) }
            try await pending.change.commit()
        }
    }
}
