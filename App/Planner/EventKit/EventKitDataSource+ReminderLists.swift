import EventKit

extension EventKitDataSource {
    public func createReminderList(_ draft: ReminderListDraft) async throws -> String {
        guard draft.isValid else { throw ReminderEditingError.invalidDraft }
        guard let source = eventStore.source(withIdentifier: draft.accountIdentifier) else {
            throw ReminderEditingError.accountNotFound
        }
        let list = EKCalendar(for: .reminder, eventStore: eventStore)
        list.title = draft.trimmedTitle
        list.source = source
        list.cgColor = draft.color.cgColor
        try eventStore.saveCalendar(list, commit: true)
        return list.calendarIdentifier
    }
}
