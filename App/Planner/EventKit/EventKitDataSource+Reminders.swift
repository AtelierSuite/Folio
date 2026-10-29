import EventKit

extension EventKitDataSource {
    @concurrent
    public func reminders(completedIn interval: DateInterval) async -> [ReminderItem] {
        guard authorizationStatus(for: .reminder).allowsReading else { return [] }
        let incomplete = eventStore.predicateForIncompleteReminders(
            withDueDateStarting: nil,
            ending: nil,
            calendars: nil
        )
        let completed = eventStore.predicateForCompletedReminders(
            withCompletionDateStarting: interval.start,
            ending: interval.end,
            calendars: nil
        )
        async let incompleteReminders = fetchReminders(matching: incomplete)
        async let completedReminders = fetchReminders(matching: completed)
        return await incompleteReminders + completedReminders
    }

    public func setCompleted(_ isCompleted: Bool, reminderIdentifier: String) async throws {
        guard let reminder = eventStore.calendarItem(withIdentifier: reminderIdentifier) as? EKReminder else {
            throw CalendarDataSourceError.itemNotFound
        }
        reminder.isCompleted = isCompleted
        try eventStore.save(reminder, commit: true)
    }

    private func fetchReminders(matching predicate: NSPredicate) async -> [ReminderItem] {
        await withCheckedContinuation { continuation in
            _ = eventStore.fetchReminders(matching: predicate) { reminders in
                continuation.resume(returning: (reminders ?? []).map(ReminderItem.init))
            }
        }
    }
}
