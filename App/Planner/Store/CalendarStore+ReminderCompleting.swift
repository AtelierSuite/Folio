import Foundation

extension CalendarStore: ReminderCompleting {
    public func completeReminder(_ reference: CalendarItemReference) async throws {
        do {
            try await source.setCompleted(true, reminderIdentifier: reference.localIdentifier)
        } catch CalendarDataSourceError.itemNotFound {
            guard let reminder = await reminder(matching: reference) else { throw CalendarDataSourceError.itemNotFound }
            try await source.setCompleted(true, reminderIdentifier: reminder.reference.localIdentifier)
        }
        await handleExternalChange()
    }
}
