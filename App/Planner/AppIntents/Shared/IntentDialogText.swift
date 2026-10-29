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

    public static func eventTime(_ event: CalendarEvent, now: Date = .now) -> String {
        event.isAllDay ? IntentDateText.day(event.startDate) : IntentDateText.time(event.startDate, now: now)
    }
}
