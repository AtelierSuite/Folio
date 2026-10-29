import Foundation

extension CalendarStore {
    public var writableReminderLists: [PlannerCalendar] {
        reminderLists.filter { !$0.isReadOnly }
    }

    public var defaultReminderListIdentifier: String? {
        let writableIdentifiers = writableReminderLists.map(\.id)
        if let identifier = source.defaultReminderListIdentifier(), writableIdentifiers.contains(identifier) {
            return identifier
        }
        return writableIdentifiers.first
    }

    public func newReminderDraft(dueOn date: Date?) -> ReminderDraft {
        ReminderDraft(listIdentifier: defaultReminderListIdentifier ?? "", dueDate: date)
    }

    @discardableResult
    public func createReminder(_ draft: ReminderDraft) async throws -> String {
        try validate(draft)
        let identifier = try await source.createReminder(draft.normalized())
        await handleExternalChange()
        return identifier
    }

    public func updateReminder(_ reminder: ReminderItem, with draft: ReminderDraft) async throws {
        guard !reminder.isReadOnly else { throw ReminderEditingError.readOnly }
        try validate(draft)
        try await source.updateReminder(identifier: reminder.reference.localIdentifier, with: draft.normalized())
        await handleExternalChange()
    }

    public func deleteReminder(_ reminder: ReminderItem) async throws {
        guard !reminder.isReadOnly else { throw ReminderEditingError.readOnly }
        try await source.deleteReminder(identifier: reminder.reference.localIdentifier)
        await handleExternalChange()
    }

    func saveReminder(identifier: String, with draft: ReminderDraft) async throws {
        try await source.updateReminder(identifier: identifier, with: draft.normalized())
        await handleExternalChange()
    }

    private func validate(_ draft: ReminderDraft) throws {
        guard draft.isValid else { throw ReminderEditingError.invalidDraft }
        guard let list = reminderLists.first(where: { $0.id == draft.listIdentifier }) else {
            throw ReminderEditingError.listNotFound
        }
        guard !list.isReadOnly else { throw ReminderEditingError.readOnly }
    }
}
