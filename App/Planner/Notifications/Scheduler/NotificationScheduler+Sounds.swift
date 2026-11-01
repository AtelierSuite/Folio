import Foundation

extension NotificationScheduler {
    public func sound(for kind: CalendarItemKind) -> NotificationSound {
        kind == .event ? eventSound : reminderSound
    }

    public func setSound(_ sound: NotificationSound, for kind: CalendarItemKind) async {
        switch kind {
        case .event: eventSound = sound
        case .reminder: reminderSound = sound
        }
        soundSettings.setSound(sound, for: kind)
        await replan()
    }

    public func sound(forCalendar calendarIdentifier: String) -> NotificationSound? {
        calendarSounds[calendarIdentifier]
    }

    public func setSound(_ sound: NotificationSound?, forCalendar calendarIdentifier: String) async {
        calendarSounds[calendarIdentifier] = sound
        soundSettings.setSound(sound, forCalendar: calendarIdentifier)
        await replan()
    }
}
