import Foundation

public struct NotificationSoundSettings: @unchecked Sendable {
    public static let eventSoundKey = "Notifications.EventSound"
    public static let reminderSoundKey = "Notifications.ReminderSound"
    public static let calendarSoundsKey = "Notifications.CalendarSounds"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public func sound(for kind: CalendarItemKind) -> NotificationSound {
        defaults.string(forKey: Self.key(for: kind)).flatMap(NotificationSound.init(rawValue:)) ?? .system
    }

    public func setSound(_ sound: NotificationSound, for kind: CalendarItemKind) {
        defaults.set(sound == .system ? nil : sound.rawValue, forKey: Self.key(for: kind))
    }

    public var calendarSounds: [String: NotificationSound] {
        let stored = defaults.dictionary(forKey: Self.calendarSoundsKey) as? [String: String] ?? [:]
        return stored.compactMapValues(NotificationSound.init(rawValue:))
    }

    public func setSound(_ sound: NotificationSound?, forCalendar calendarIdentifier: String) {
        var sounds = calendarSounds
        sounds[calendarIdentifier] = sound
        defaults.set(sounds.mapValues(\.rawValue), forKey: Self.calendarSoundsKey)
    }

    public func resolvedSound(for candidate: NotificationCandidate) -> NotificationSound {
        calendarSounds[candidate.reference.calendarIdentifier] ?? sound(for: candidate.kind)
    }

    private static func key(for kind: CalendarItemKind) -> String {
        kind == .event ? eventSoundKey : reminderSoundKey
    }
}
