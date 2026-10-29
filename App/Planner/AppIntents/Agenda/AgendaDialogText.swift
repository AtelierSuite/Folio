import Foundation

enum AgendaDialogText {
    static let spokenEventLimit = 5

    static func nothingNext() -> String {
        IntentStrings.string("Dialog.NothingNext")
    }

    static func upNext(_ event: CalendarEvent, now: Date, calendar: Calendar) -> String {
        if event.startDate <= now {
            let end = IntentDateText.time(event.endDate, now: now, calendar: calendar)
            return IntentStrings.string("Dialog.HappeningNow \(event.title) \(end)")
        }
        let start = IntentDateText.time(event.startDate, now: now, calendar: calendar)
        return IntentStrings.string("Dialog.UpNext \(event.title) \(start)")
    }

    static func todayClear() -> String {
        IntentStrings.string("Dialog.TodayClear")
    }

    static func today(events: [CalendarEvent], reminders: [ReminderItem], now: Date, calendar: Calendar) -> String {
        guard !events.isEmpty || !reminders.isEmpty else { return todayClear() }
        var sentences: [String] = []
        if events.isEmpty {
            sentences.append(IntentStrings.string("Dialog.TodayNoEvents"))
        } else {
            let items = events.prefix(spokenEventLimit).map { spokenItem(for: $0, now: now, calendar: calendar) }
            let list = items.formatted(.list(type: .and))
            sentences.append(IntentStrings.string("Dialog.TodayEvents \(list)"))
            if events.count > spokenEventLimit {
                sentences.append(IntentStrings.string("Dialog.TodayMoreEvents \(events.count - spokenEventLimit)"))
            }
        }
        if !reminders.isEmpty {
            let list = reminders.prefix(spokenEventLimit).map(\.title).formatted(.list(type: .and))
            sentences.append(IntentStrings.string("Dialog.TodayReminders \(list)"))
        }
        return sentences.joined(separator: " ")
    }

    private static func spokenItem(for event: CalendarEvent, now: Date, calendar: Calendar) -> String {
        guard !event.isAllDay else { return event.title }
        let time = IntentDateText.time(event.startDate, now: now, calendar: calendar)
        return IntentStrings.string("Dialog.EventAtTime \(event.title) \(time)")
    }
}
