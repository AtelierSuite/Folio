import Foundation

@MainActor
public protocol NotificationRouting: AnyObject {
    func open(_ route: NotificationRoute)
}

@MainActor
public protocol ReminderCompleting: AnyObject {
    func completeReminder(_ reference: CalendarItemReference) async throws
}
