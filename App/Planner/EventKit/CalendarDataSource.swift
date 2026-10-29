import Foundation

public protocol CalendarDataSource: Sendable {
    func authorizationStatus(for kind: CalendarItemKind) -> CalendarAuthorizationStatus
    func requestFullAccess(to kind: CalendarItemKind) async throws -> Bool
    func calendars(for kind: CalendarItemKind) -> [PlannerCalendar]
    @concurrent func events(in interval: DateInterval) async -> [CalendarEvent]
    @concurrent func reminders(completedIn interval: DateInterval) async -> [ReminderItem]
    func setCompleted(_ isCompleted: Bool, reminderIdentifier: String) async throws
    func changes() -> AsyncStream<Void>
}
