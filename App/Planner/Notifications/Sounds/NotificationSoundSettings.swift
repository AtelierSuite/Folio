import Foundation

public struct NotificationSoundSettings: @unchecked Sendable {
    public static let eventSoundKey = "Notifications.EventSound"
    public static let reminderSoundKey = "Notifications.ReminderSound"

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

    private static func key(for kind: CalendarItemKind) -> String {
        kind == .event ? eventSoundKey : reminderSoundKey
    }
}
