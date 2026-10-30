import Foundation

/// The reminders in one list: open ones by due date (undated last), then ones completed since `completedSince`.
public enum ReminderListContents {
    public static func reminders(
        from reminders: [ReminderItem],
        inList listIdentifier: String,
        completedSince: Date
    ) -> [ReminderItem] {
        reminders
            .filter { $0.listIdentifier == listIdentifier && isShown($0, completedSince: completedSince) }
            .sorted(by: displayOrder)
    }

    public static func openCounts(from reminders: [ReminderItem]) -> [String: Int] {
        reminders
            .filter { !$0.isCompleted }
            .reduce(into: [:]) { counts, reminder in counts[reminder.listIdentifier, default: 0] += 1 }
    }

    private static func isShown(_ reminder: ReminderItem, completedSince: Date) -> Bool {
        guard reminder.isCompleted else { return true }
        return reminder.completionDate.map { $0 >= completedSince } ?? false
    }

    private static func displayOrder(_ lhs: ReminderItem, _ rhs: ReminderItem) -> Bool {
        if lhs.isCompleted != rhs.isCompleted { return !lhs.isCompleted }
        switch (lhs.dueDate, rhs.dueDate) {
        case let (lhsDate?, rhsDate?) where lhsDate != rhsDate: return lhsDate < rhsDate
        case (.some, nil): return true
        case (nil, .some): return false
        default: break
        }
        let order = lhs.title.localizedStandardCompare(rhs.title)
        if order != .orderedSame { return order == .orderedAscending }
        return lhs.id < rhs.id
    }
}
