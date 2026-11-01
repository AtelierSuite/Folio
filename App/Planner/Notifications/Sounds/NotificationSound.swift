import Foundation

public enum NotificationSound: String, Sendable, Hashable, CaseIterable, Codable, Identifiable {
    case system
    case furin = "Calendar-Furin"
    case asahi = "Calendar-Asahi"
    case sakura = "Calendar-Sakura"
    case uguisu = "Calendar-Uguisu"
    case seseragi = "Calendar-Seseragi"
    case hoshizora = "Calendar-Hoshizora"
    case niji = "Calendar-Niji"
    case kumo = "Calendar-Kumo"
    case nami = "Calendar-Nami"
    case kaze = "Calendar-Kaze"
    case shizuku = "Reminder-Shizuku"
    case hotaru = "Reminder-Hotaru"
    case momiji = "Reminder-Momiji"
    case tsuki = "Reminder-Tsuki"
    case kiri = "Reminder-Kiri"
    case hamon = "Reminder-Hamon"
    case suzu = "Reminder-Suzu"
    case hana = "Reminder-Hana"
    case yuki = "Reminder-Yuki"
    case mejiro = "Reminder-Mejiro"

    public static let fileExtension = "caf"

    public var id: String { rawValue }

    public var fileName: String? {
        self == .system ? nil : "\(rawValue).\(Self.fileExtension)"
    }

    public static func choices(for kind: CalendarItemKind) -> [NotificationSound] {
        let prefix = kind == .event ? "Calendar-" : "Reminder-"
        return [.system] + allCases.filter { $0.rawValue.hasPrefix(prefix) }
    }
}
