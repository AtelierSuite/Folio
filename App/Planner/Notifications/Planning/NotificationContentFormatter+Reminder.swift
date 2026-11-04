import Foundation

extension NotificationContentFormatter {
    private static let notesLimit = 200

    func reminderDetails(for reminder: ReminderItem) -> NotificationReminderDetails {
        NotificationReminderDetails(
            dueDate: reminder.dueDate,
            hasDueTime: reminder.hasDueTime,
            priorityMarks: priorityMarks(for: ReminderPriority(eventKitPriority: reminder.priority)),
            notes: trimmedNotes(reminder.notes),
            repeatText: repeatText(for: reminder)
        )
    }

    private func priorityMarks(for priority: ReminderPriority) -> String? {
        switch priority {
        case .none: nil
        case .low: "!"
        case .medium: "!!"
        case .high: "!!!"
        }
    }

    private func trimmedNotes(_ notes: String?) -> String? {
        guard let notes = notes?.trimmingCharacters(in: .whitespacesAndNewlines), !notes.isEmpty else { return nil }
        return String(notes.prefix(Self.notesLimit))
    }

    private func repeatText(for reminder: ReminderItem) -> String? {
        guard let recurrence = reminder.recurrence else {
            return reminder.isRecurring ? customRepeatText : nil
        }
        guard recurrence.interval == 1 else { return customRepeatText }
        return switch recurrence.frequency {
        case .daily: String(localized: "Repeat.Daily", table: "Notifications", bundle: #bundle)
        case .weekly: String(localized: "Repeat.Weekly", table: "Notifications", bundle: #bundle)
        case .monthly: String(localized: "Repeat.Monthly", table: "Notifications", bundle: #bundle)
        case .yearly: String(localized: "Repeat.Yearly", table: "Notifications", bundle: #bundle)
        }
    }

    private var customRepeatText: String {
        String(localized: "Repeat.Custom", table: "Notifications", bundle: #bundle)
    }
}
