import Foundation

extension NotificationUserInfo {
    static func isAlert(_ userInfo: [AnyHashable: Any], for reminder: CalendarItemReference) -> Bool {
        guard kind(from: userInfo) == .reminder, let reference = reference(from: userInfo) else { return false }
        return reference.identifiesSameItem(as: reminder)
    }
}

extension CalendarItemReference {
    func identifiesSameItem(as other: CalendarItemReference) -> Bool {
        if localIdentifier == other.localIdentifier { return true }
        guard let externalIdentifier else { return false }
        return externalIdentifier == other.externalIdentifier
    }
}
