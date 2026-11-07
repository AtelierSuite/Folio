import Foundation
import UserNotifications

extension UNNotificationContent {
    func keptCopy() -> UNNotificationContent {
        guard let copy = mutableCopy() as? UNMutableNotificationContent else { return self }
        if !NotificationUserInfo.isKept(userInfo) {
            copy.userInfo[NotificationUserInfo.keptInterruptionLevelKey] = interruptionLevel.rawValue
        }
        copy.interruptionLevel = .passive
        copy.sound = nil
        return copy
    }

    /// A kept copy is silent, so snoozing one has to bring back the original alert's sound and level.
    func restoredFromKeptCopy() -> UNNotificationContent {
        guard let level = NotificationUserInfo.keptInterruptionLevel(from: userInfo),
              let copy = mutableCopy() as? UNMutableNotificationContent else { return self }
        copy.userInfo[NotificationUserInfo.keptInterruptionLevelKey] = nil
        copy.interruptionLevel = level
        copy.sound = Self.sound(for: NotificationUserInfo.sound(from: userInfo) ?? .system)
        return copy
    }
}
