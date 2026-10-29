import Foundation

extension CalendarStore {
    public var hasPendingChanges: Bool {
        !pendingRemovals.isEmpty || !pendingEventEdits.isEmpty
    }

    public func isPendingRemoval(_ document: SearchDocument) -> Bool {
        guard case .calendarDay(_, let reference?) = document.destination else { return false }
        let kind: CalendarItemKind
        switch document.kind {
        case .event: kind = .event
        case .reminder: kind = .reminder
        case .note: return false
        }
        return pendingRemovals.values.contains { $0.hides(reference, kind: kind) }
    }

    func hide(_ removal: PendingRemoval) -> UUID {
        let identifier = UUID()
        pendingRemovals[identifier] = removal
        contentRevision += 1
        return identifier
    }

    func hold(_ edit: PendingEventEdit) -> UUID {
        let identifier = UUID()
        pendingEventEdits[identifier] = edit
        contentRevision += 1
        return identifier
    }

    func clearPendingChange(_ identifier: UUID) {
        let removedRemoval = pendingRemovals.removeValue(forKey: identifier)
        let removedEdit = pendingEventEdits.removeValue(forKey: identifier)
        guard removedRemoval != nil || removedEdit != nil else { return }
        contentRevision += 1
    }

    func applyingPendingChanges(to events: [CalendarEvent]) -> [CalendarEvent] {
        guard hasPendingChanges else { return events }
        return events.compactMap { event in
            if pendingRemovals.values.contains(where: { $0.hides(event) }) { return nil }
            guard let edit = pendingEdit(covering: event) else { return event }
            return edit.preview(of: event, color: calendar(withIdentifier: edit.draft.calendarIdentifier)?.color)
        }
    }

    func applyingPendingChanges(to reminders: [ReminderItem]) -> [ReminderItem] {
        guard !pendingRemovals.isEmpty else { return reminders }
        return reminders.filter { reminder in
            !pendingRemovals.values.contains { $0.hides(reminder) }
        }
    }

    func pendingEdit(covering event: CalendarEvent) -> PendingEventEdit? {
        pendingEventEdits.values.first { $0.covers(event) }
    }
}
