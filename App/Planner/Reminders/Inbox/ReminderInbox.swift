import Foundation

/// Reminders without a due date. Ones completed since `completedSince` stay listed, checked.
public enum ReminderInbox {
    public static func reminders(from reminders: [ReminderItem], completedSince: Date) -> [ReminderItem] {
        reminders
            .filter { $0.dueDate == nil && isShown($0, completedSince: completedSince) }
            .sorted(by: displayOrder)
    }

    private static func isShown(_ reminder: ReminderItem, completedSince: Date) -> Bool {
        guard reminder.isCompleted else { return true }
        return reminder.completionDate.map { $0 >= completedSince } ?? false
    }

    private static func displayOrder(_ lhs: ReminderItem, _ rhs: ReminderItem) -> Bool {
        if lhs.isCompleted != rhs.isCompleted { return !lhs.isCompleted }
        let order = lhs.title.localizedStandardCompare(rhs.title)
        if order != .orderedSame { return order == .orderedAscending }
        return lhs.id < rhs.id
    }
}
