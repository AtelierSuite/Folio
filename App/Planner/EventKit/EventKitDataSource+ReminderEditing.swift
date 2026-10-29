import EventKit

extension EventKitDataSource {
    public func defaultReminderListIdentifier() -> String? {
        guard authorizationStatus(for: .reminder).allowsReading else { return nil }
        return eventStore.defaultCalendarForNewReminders()?.calendarIdentifier
    }

    public func createReminder(_ draft: ReminderDraft) async throws -> String {
        let reminder = EKReminder(eventStore: eventStore)
        try apply(draft.normalized(), to: reminder, isNew: true)
        try eventStore.save(reminder, commit: true)
        return reminder.calendarItemIdentifier
    }

    public func updateReminder(identifier: String, with draft: ReminderDraft) async throws {
        let reminder = try existingReminder(withIdentifier: identifier)
        try apply(draft.normalized(), to: reminder, isNew: false)
        try eventStore.save(reminder, commit: true)
    }

    public func deleteReminder(identifier: String) async throws {
        let reminder = try existingReminder(withIdentifier: identifier)
        guard reminder.calendar?.allowsContentModifications ?? false else {
            throw ReminderEditingError.readOnly
        }
        try eventStore.remove(reminder, commit: true)
    }

    private func existingReminder(withIdentifier identifier: String) throws -> EKReminder {
        guard let reminder = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder else {
            throw CalendarDataSourceError.itemNotFound
        }
        return reminder
    }

    private func apply(_ draft: ReminderDraft, to reminder: EKReminder, isNew: Bool) throws {
        guard draft.isValid else { throw ReminderEditingError.invalidDraft }
        guard let list = eventStore.calendar(withIdentifier: draft.listIdentifier) else {
            throw ReminderEditingError.listNotFound
        }
        guard list.allowsContentModifications,
              isNew || reminder.calendar?.allowsContentModifications ?? false else {
            throw ReminderEditingError.readOnly
        }
        reminder.calendar = list
        reminder.title = draft.title
        reminder.notes = draft.notes.isEmpty ? nil : draft.notes
        reminder.url = draft.url
        reminder.priority = draft.priority.rawValue
        applySchedule(of: draft, to: reminder)
        applyAlarms(draft.alarms, to: reminder)
    }

    private func applySchedule(of draft: ReminderDraft, to reminder: EKReminder) {
        let existingRecurrence = reminder.recurrenceRules?.first.map(ReminderRecurrence.init)
        if existingRecurrence != draft.recurrence {
            reminder.recurrenceRules?.forEach(reminder.removeRecurrenceRule)
        }
        reminder.dueDateComponents = draft.dueDateComponents()
        if existingRecurrence != draft.recurrence, let recurrence = draft.recurrence {
            reminder.addRecurrenceRule(recurrence.eventKitRule)
        }
    }

    private func applyAlarms(_ alarms: [ReminderAlarm], to reminder: EKReminder) {
        let existingAlarms = reminder.alarms ?? []
        guard existingAlarms.compactMap(ReminderAlarm.init) != alarms else { return }
        for alarm in existingAlarms where ReminderAlarm(alarm) != nil {
            reminder.removeAlarm(alarm)
        }
        alarms.map(\.eventKitAlarm).forEach(reminder.addAlarm)
    }
}
