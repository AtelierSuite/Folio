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
}
