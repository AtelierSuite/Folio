import Foundation

public protocol CalendarDataSource: EventWritingDataSource {
    func authorizationStatus(for kind: CalendarItemKind) -> CalendarAuthorizationStatus
    func requestFullAccess(to kind: CalendarItemKind) async throws -> Bool
    func calendars(for kind: CalendarItemKind) -> [PlannerCalendar]
    @concurrent func events(in interval: DateInterval) async -> [CalendarEvent]
    @concurrent func reminders(completedIn interval: DateInterval) async -> [ReminderItem]
    func setCompleted(_ isCompleted: Bool, reminderIdentifier: String) async throws
    func changes() -> AsyncStream<Void>
    func defaultReminderListIdentifier() -> String?
    func createReminder(_ draft: ReminderDraft) async throws -> String
    func updateReminder(identifier: String, with draft: ReminderDraft) async throws
    func deleteReminder(identifier: String) async throws
}
