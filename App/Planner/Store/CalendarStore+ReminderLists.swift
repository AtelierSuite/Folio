import Foundation

extension CalendarStore {
    /// Lists ignore calendar visibility: hiding a list only hides it from the calendar.
    public func reminders(inList listIdentifier: String, calendar: Calendar = .current) async -> [ReminderItem] {
        let startOfToday = calendar.startOfDay(for: now())
        let reminders = await allReminders(around: startOfToday)
        return ReminderListContents.reminders(from: reminders, inList: listIdentifier, completedSince: startOfToday)
    }

    public func openReminderCounts(calendar: Calendar = .current) async -> [String: Int] {
        let startOfToday = calendar.startOfDay(for: now())
        return ReminderListContents.openCounts(from: await allReminders(around: startOfToday))
    }

    private func allReminders(around startOfToday: Date) async -> [ReminderItem] {
        let today = DateInterval(start: startOfToday, duration: 1)
        return applyingPendingChanges(to: await repository.reminders(around: today))
    }
}

extension CalendarStore {
    public var reminderListAccounts: [ReminderListAccount] {
        ReminderListAccount.accounts(from: reminderLists)
    }

    public var defaultReminderListAccountIdentifier: String? {
        let defaultList = reminderLists.first { $0.id == defaultReminderListIdentifier }
        return defaultList?.sourceIdentifier ?? reminderListAccounts.first?.id
    }

    public func createReminderList(_ draft: ReminderListDraft) async throws -> PlannerCalendar {
        guard draft.isValid else { throw ReminderEditingError.invalidDraft }
        guard reminderListAccounts.contains(where: { $0.id == draft.accountIdentifier }) else {
            throw ReminderEditingError.accountNotFound
        }
        let identifier = try await source.createReminderList(draft)
        await handleExternalChange()
        guard let list = reminderLists.first(where: { $0.id == identifier }) else {
            throw ReminderEditingError.listNotFound
        }
        return list
    }
}
