import Foundation

public enum NotificationSound: String, Sendable, Hashable, CaseIterable, Codable, Identifiable {
    case system
    case furin = "Calendar-Furin"
    case shishiOdoshi = "Calendar-ShishiOdoshi"
    case bonsho = "Calendar-Bonsho"
    case suikinkutsu = "Calendar-Suikinkutsu"
    case uguisu = "Calendar-Uguisu"
    case koto = "Calendar-Koto"
    case shakuhachi = "Calendar-Shakuhachi"
    case sakura = "Calendar-Sakura"
    case seseragi = "Calendar-Seseragi"
    case higurashi = "Calendar-Higurashi"
    case shizuku = "Reminder-Shizuku"
    case hotaru = "Reminder-Hotaru"
    case kaeru = "Reminder-Kaeru"
    case suzumushi = "Reminder-Suzumushi"
    case momiji = "Reminder-Momiji"
    case take = "Reminder-Take"
    case mejiro = "Reminder-Mejiro"
    case kiri = "Reminder-Kiri"
    case hamon = "Reminder-Hamon"
    case rin = "Reminder-Rin"

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
