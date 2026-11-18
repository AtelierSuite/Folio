import Foundation

/// Listed from the gentlest to the most urgent.
public enum AlarmSound: String, Sendable, Hashable, CaseIterable, Codable, Identifiable {
    case system
    case yoake = "Alarm-Yoake"
    case komorebi = "Alarm-Komorebi"
    case hibari = "Alarm-Hibari"
    case shiokaze = "Alarm-Shiokaze"
    case hibiki = "Alarm-Hibiki"
    case hidamari = "Alarm-Hidamari"
    case tsubame = "Alarm-Tsubame"
    case arashi = "Alarm-Arashi"
    case hayate = "Alarm-Hayate"
    case kaminari = "Alarm-Kaminari"

    public static let fileExtension = "caf"

    public var id: String { rawValue }

    public var fileName: String? {
        self == .system ? nil : "\(rawValue).\(Self.fileExtension)"
    }

    /// Alarms are matched to scheduled ones by identifier, so a new sound needs a new identifier to reschedule.
    func alarmIdentifier(fromNotificationIdentifier identifier: String) -> UUID {
        AlarmIdentifier.make(fromNotificationIdentifier: self == .system ? identifier : "\(identifier)|\(rawValue)")
    }
}
