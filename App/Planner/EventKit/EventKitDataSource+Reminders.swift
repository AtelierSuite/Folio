import EventKit

extension EventKitDataSource {
    @concurrent
    public func reminders(completedIn interval: DateInterval) async -> [ReminderItem] {
        async let incomplete = incompleteReminders()
        async let completed = completedReminders(in: interval)
        return await incomplete + completed
    }

    @concurrent
    public func incompleteReminders() async -> [ReminderItem] {
        guard authorizationStatus(for: .reminder).allowsReading else { return [] }
        let predicate = eventStore.predicateForIncompleteReminders(
            withDueDateStarting: nil,
            ending: nil,
            calendars: nil
        )
        return await fetchReminders(matching: predicate)
    }

    @concurrent
    public func completedReminders(in interval: DateInterval) async -> [ReminderItem] {
        guard authorizationStatus(for: .reminder).allowsReading else { return [] }
        let predicate = eventStore.predicateForCompletedReminders(
            withCompletionDateStarting: interval.start,
            ending: interval.end,
            calendars: nil
        )
        return await fetchReminders(matching: predicate)
    }

    @concurrent
    public func setCompleted(_ isCompleted: Bool, reminderIdentifier: String) async throws {
        guard let reminder = eventStore.calendarItem(withIdentifier: reminderIdentifier) as? EKReminder else {
            throw CalendarDataSourceError.itemNotFound
        }
        reminder.isCompleted = isCompleted
        try eventStore.persist(reminder)
    }

    private func fetchReminders(matching predicate: NSPredicate) async -> [ReminderItem] {
        await withCheckedContinuation { continuation in
            _ = eventStore.fetchReminders(matching: predicate) { reminders in
                continuation.resume(returning: (reminders ?? []).map(ReminderItem.init))
            }
        }
    }
}
