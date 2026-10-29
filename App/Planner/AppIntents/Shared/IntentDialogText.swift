import Foundation

/// What Siri says after an intent runs.
public enum IntentDialogText {
    static func eventCreated(_ event: CalendarEvent, now: Date = .now) -> String {
        IntentStrings.string("Dialog.EventCreated \(event.title) \(eventTime(event, now: now))")
    }

    static func eventUpdated(_ event: CalendarEvent, now: Date = .now) -> String {
        IntentStrings.string("Dialog.EventUpdated \(event.title) \(eventTime(event, now: now))")
    }

    static func confirmEventDeletion(_ event: CalendarEvent, now: Date = .now) -> String {
        IntentStrings.string("Dialog.ConfirmEventDeletion \(event.title) \(eventTime(event, now: now))")
    }

    static func eventDeleted(_ event: CalendarEvent) -> String {
        IntentStrings.string("Dialog.EventDeleted \(event.title)")
    }

    static func reminderCreated(_ reminder: ReminderItem) -> String {
        guard let due = reminderDue(reminder) else {
            return IntentStrings.string("Dialog.ReminderCreated \(reminder.title)")
        }
        return IntentStrings.string("Dialog.ReminderCreatedDue \(reminder.title) \(due)")
    }

    static func reminderUpdated(_ reminder: ReminderItem) -> String {
        IntentStrings.string("Dialog.ReminderUpdated \(reminder.title)")
    }

    static func confirmReminderDeletion(_ reminder: ReminderItem) -> String {
        IntentStrings.string("Dialog.ConfirmReminderDeletion \(reminder.title)")
    }

    static func reminderDeleted(_ reminder: ReminderItem) -> String {
        IntentStrings.string("Dialog.ReminderDeleted \(reminder.title)")
    }

    static func reminderCompletion(_ reminder: ReminderItem, isCompleted: Bool) -> String {
        isCompleted
            ? IntentStrings.string("Dialog.ReminderCompleted \(reminder.title)")
            : IntentStrings.string("Dialog.ReminderReopened \(reminder.title)")
    }

    static func reminderDue(_ reminder: ReminderItem) -> String? {
        guard let dueDate = reminder.dueDate else { return nil }
        return reminder.hasDueTime ? IntentDateText.time(dueDate) : IntentDateText.day(dueDate)
    }

    public static func eventTime(_ event: CalendarEvent, now: Date = .now) -> String {
        event.isAllDay ? IntentDateText.day(event.startDate) : IntentDateText.time(event.startDate, now: now)
    }
}
