import Foundation

extension UndoCoordinator {
    /// Creates a reminder from the event (the whole series, if it repeats) and hides the event,
    /// deleting it once the toast expires. Undo deletes the reminder and shows the event again.
    public func convertEvent(_ event: CalendarEvent, toReminderIn listIdentifier: String) async throws {
        guard !event.isReadOnly else { throw EventEditingError.readOnly }
        await beginAction()
        let eventDraft = if event.isRecurring {
            try await store.source.eventDraft(for: store.source.firstOccurrence(of: event.reference).reference)
        } else {
            try await store.eventDraft(for: event)
        }
        let draft = eventDraft.convertedToReminder(listIdentifier: listIdentifier)
        let created = CreatedItem(try await store.createReminder(draft))
        let span: EventEditSpan = event.isRecurring ? .allEvents : .thisEvent
        let removal = PendingRemoval.event(
            localIdentifier: event.reference.localIdentifier,
            occurrenceDate: event.reference.occurrenceDate,
            span: span
        )
        record(stage(DeferredChange(
            action: .convert(.event),
            stage: { [store] in store.hide(removal) },
            unstage: { [store] in store.clearPendingChange($0) },
            commit: { [store] in try await store.deleteEvent(event, span: span) },
            revert: { [store] in
                guard let identifier = created.take() else { return }
                try await store.removeCreatedReminder(identifier: identifier)
            },
            reapply: { [store] in created.value = try await store.createReminder(draft) }
        )))
    }

    /// Creates an event from the reminder and hides the reminder, deleting it once the toast
    /// expires. Undo deletes the event and shows the reminder again.
    public func convertReminder(_ reminder: ReminderItem, toEventIn calendarIdentifier: String) async throws {
        guard !reminder.isReadOnly else { throw ReminderEditingError.readOnly }
        let draft = ReminderDraft(reminder).convertedToEvent(calendarIdentifier: calendarIdentifier)
        try store.validate(draft)
        await beginAction()
        let created = CreatedItem(try await store.createEvent(draft))
        let isRecurring = draft.recurrence != nil
        let removal = PendingRemoval.reminder(localIdentifier: reminder.reference.localIdentifier)
        record(stage(DeferredChange(
            action: .convert(.reminder),
            stage: { [store] in store.hide(removal) },
            unstage: { [store] in store.clearPendingChange($0) },
            commit: { [store] in try await store.deleteReminder(reminder) },
            revert: { [store] in
                guard let reference = created.take() else { return }
                try await store.removeCreatedEvent(at: reference, isRecurring: isRecurring)
            },
            reapply: { [store] in created.value = try await store.createEvent(draft) }
        )))
    }
}

/// The item a conversion created, which undo deletes and redo creates again under a new identifier.
@MainActor
private final class CreatedItem<Value> {
    var value: Value?

    init(_ value: Value) {
        self.value = value
    }

    func take() -> Value? {
        defer { value = nil }
        return value
    }
}
