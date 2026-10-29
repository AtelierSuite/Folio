import Foundation

extension UndoCoordinator {
    /// Hides the reminder and deletes it once the toast expires.
    public func deleteReminder(_ reminder: ReminderItem) async throws {
        guard !reminder.isReadOnly else { throw ReminderEditingError.readOnly }
        await beginAction()
        let removal = PendingRemoval.reminder(localIdentifier: reminder.reference.localIdentifier)
        record(stage(DeferredChange(
            action: .delete(.reminder),
            stage: { [store] in store.hide(removal) },
            unstage: { [store] in store.clearPendingChange($0) },
            commit: { [store] in try await store.deleteReminder(reminder) }
        )))
    }

    public func updateReminder(
        _ reminder: ReminderItem,
        with draft: ReminderDraft,
        action: UndoAction = .edit(.reminder)
    ) async throws {
        await beginAction()
        let originalDraft = ReminderDraft(reminder)
        try await store.updateReminder(reminder, with: draft)
        let identifier = reminder.reference.localIdentifier
        record(.reversible(
            action,
            undo: { [store] in try await store.saveReminder(identifier: identifier, with: originalDraft) },
            redo: { [store] in try await store.saveReminder(identifier: identifier, with: draft) }
        ))
    }

    public func setCompleted(_ isCompleted: Bool, for reminder: ReminderItem) async throws {
        await beginAction()
        try await store.setCompleted(isCompleted, for: reminder)
        let wasCompleted = reminder.isCompleted
        record(.reversible(
            isCompleted ? .complete : .uncomplete,
            undo: { [store] in try await store.setCompleted(wasCompleted, for: reminder) },
            redo: { [store] in try await store.setCompleted(isCompleted, for: reminder) }
        ))
    }
}
