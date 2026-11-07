import Foundation
import UserNotifications

extension NotificationUserInfo {
    static let keptInterruptionLevelKey = "keptInterruptionLevel"
    static let soundKey = "sound"

    public static func isKept(_ userInfo: [AnyHashable: Any]) -> Bool {
        userInfo[keptInterruptionLevelKey] != nil
    }

    static func keptInterruptionLevel(from userInfo: [AnyHashable: Any]) -> UNNotificationInterruptionLevel? {
        (userInfo[keptInterruptionLevelKey] as? UInt).flatMap(UNNotificationInterruptionLevel.init(rawValue:))
    }

    static func sound(from userInfo: [AnyHashable: Any]) -> NotificationSound? {
        (userInfo[soundKey] as? String).flatMap(NotificationSound.init(rawValue:))
    }
}

extension NotificationItem {
    static let keptPrefix = "folio.kept."

    /// Outside `NotificationIdentifier.prefix`, so a replan never treats the copy as a stale alert.
    var keptIdentifier: String {
        "\(Self.keptPrefix)\(kind.rawValue).\(reference.storageKey)"
    }
}
