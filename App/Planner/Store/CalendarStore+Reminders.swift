import Foundation

extension CalendarStore {
    /// Reminders shown in `interval`, with overdue ones moved to today when `overdueReminderPolicy` says so.
    public func reminders(in interval: DateInterval, calendar: Calendar = .current) async -> [ReminderItem] {
        visibleInterval = interval
        let reminders = await repository.reminders(around: interval)
        let schedule = ReminderSchedule(policy: overdueReminderPolicy, calendar: calendar, now: now())
        return schedule.reminders(visibleReminders(reminders), in: interval)
    }

    public func undatedReminders(calendar: Calendar = .current) async -> [ReminderItem] {
        let startOfToday = calendar.startOfDay(for: now())
        let today = DateInterval(start: startOfToday, duration: 1)
        let reminders = await repository.reminders(around: today)
        return ReminderInbox.reminders(from: visibleReminders(reminders), completedSince: startOfToday)
    }

    public func setCompleted(_ isCompleted: Bool, for reminder: ReminderItem) async throws {
        try await source.setCompleted(isCompleted, reminderIdentifier: reminder.reference.localIdentifier)
        await handleExternalChange()
    }

    public func setOverdueReminderPolicy(_ policy: OverdueReminderPolicy) {
        guard policy != overdueReminderPolicy else { return }
        overdueReminderPolicy = policy
        reminderSettings.overduePolicy = policy
        contentRevision += 1
    }

    private func visibleReminders(_ reminders: [ReminderItem]) -> [ReminderItem] {
        applyingPendingChanges(to: reminders).filter { !hiddenCalendarIdentifiers.contains($0.listIdentifier) }
    }
}
