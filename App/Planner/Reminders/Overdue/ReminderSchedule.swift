import Foundation

/// Decides which day each reminder is shown on, carrying overdue ones forward to today when asked.
public struct ReminderSchedule: Sendable {
    public let policy: OverdueReminderPolicy
    public let calendar: Calendar
    public let now: Date

    public init(policy: OverdueReminderPolicy, calendar: Calendar = .current, now: Date = .now) {
        self.policy = policy
        self.calendar = calendar
        self.now = now
    }

    public var startOfToday: Date {
        calendar.startOfDay(for: now)
    }

    public func reminders(_ reminders: [ReminderItem], in interval: DateInterval) -> [ReminderItem] {
        reminders.map(scheduled).filter { $0.isDue(in: interval) }
    }

    /// Reminders checked off today stay on today, so a mistaken tap can be undone where it happened.
    public func isOverdue(_ reminder: ReminderItem) -> Bool {
        guard let dueDate = reminder.dueDate, dueDate < startOfToday else { return false }
        guard reminder.isCompleted else { return true }
        return reminder.completionDate.map { $0 >= startOfToday } ?? false
    }

    private func scheduled(_ reminder: ReminderItem) -> ReminderItem {
        guard policy == .carryForward, isOverdue(reminder) else { return reminder }
        var carried = reminder
        carried.carriedForwardDate = startOfToday
        return carried
    }
}
