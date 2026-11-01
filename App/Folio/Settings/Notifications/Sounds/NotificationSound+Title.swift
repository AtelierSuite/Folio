import Foundation
import Planner

extension NotificationSound {
    var title: String {
        switch self {
        case .system: String(localized: "Sound.System", table: "NotificationSounds")
        case .furin: String(localized: "Sound.Furin", table: "NotificationSounds")
        case .asahi: String(localized: "Sound.Asahi", table: "NotificationSounds")
        case .sakura: String(localized: "Sound.Sakura", table: "NotificationSounds")
        case .uguisu: String(localized: "Sound.Uguisu", table: "NotificationSounds")
        case .seseragi: String(localized: "Sound.Seseragi", table: "NotificationSounds")
        case .hoshizora: String(localized: "Sound.Hoshizora", table: "NotificationSounds")
        case .niji: String(localized: "Sound.Niji", table: "NotificationSounds")
        case .kumo: String(localized: "Sound.Kumo", table: "NotificationSounds")
        case .nami: String(localized: "Sound.Nami", table: "NotificationSounds")
        case .kaze: String(localized: "Sound.Kaze", table: "NotificationSounds")
        case .shizuku: String(localized: "Sound.Shizuku", table: "NotificationSounds")
        case .hotaru: String(localized: "Sound.Hotaru", table: "NotificationSounds")
        case .momiji: String(localized: "Sound.Momiji", table: "NotificationSounds")
        case .tsuki: String(localized: "Sound.Tsuki", table: "NotificationSounds")
        case .kiri: String(localized: "Sound.Kiri", table: "NotificationSounds")
        case .hamon: String(localized: "Sound.Hamon", table: "NotificationSounds")
        case .suzu: String(localized: "Sound.Suzu", table: "NotificationSounds")
        case .hana: String(localized: "Sound.Hana", table: "NotificationSounds")
        case .yuki: String(localized: "Sound.Yuki", table: "NotificationSounds")
        case .mejiro: String(localized: "Sound.Mejiro", table: "NotificationSounds")
        }
    }
}

extension NotificationSound {
    static func inheritedTitle(_ sound: NotificationSound) -> String {
        String(localized: "Sound.Inherited \(sound.title)", table: "NotificationSounds")
    }
}
