import Foundation

/// What only reminders show in the expanded alert. Its presence selects the reminder layout.
public struct NotificationReminderDetails: Sendable, Hashable, Codable {
    public let dueDate: Date?
    public let hasDueTime: Bool
    public let priorityMarks: String?
    public let notes: String?
    public let repeatText: String?

    public init(
        dueDate: Date?,
        hasDueTime: Bool,
        priorityMarks: String? = nil,
        notes: String? = nil,
        repeatText: String? = nil
    ) {
        self.dueDate = dueDate
        self.hasDueTime = hasDueTime
        self.priorityMarks = priorityMarks
        self.notes = notes
        self.repeatText = repeatText
    }
}
