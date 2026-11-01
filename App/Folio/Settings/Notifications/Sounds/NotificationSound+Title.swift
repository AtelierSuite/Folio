import Foundation
import Planner

extension NotificationSound {
    var title: String {
        switch self {
        case .system: String(localized: "Sound.System", table: "NotificationSounds")
        case .furin: String(localized: "Sound.Furin", table: "NotificationSounds")
        case .shishiOdoshi: String(localized: "Sound.ShishiOdoshi", table: "NotificationSounds")
        case .bonsho: String(localized: "Sound.Bonsho", table: "NotificationSounds")
        case .suikinkutsu: String(localized: "Sound.Suikinkutsu", table: "NotificationSounds")
        case .uguisu: String(localized: "Sound.Uguisu", table: "NotificationSounds")
        case .koto: String(localized: "Sound.Koto", table: "NotificationSounds")
        case .shakuhachi: String(localized: "Sound.Shakuhachi", table: "NotificationSounds")
        case .sakura: String(localized: "Sound.Sakura", table: "NotificationSounds")
        case .seseragi: String(localized: "Sound.Seseragi", table: "NotificationSounds")
        case .higurashi: String(localized: "Sound.Higurashi", table: "NotificationSounds")
        case .shizuku: String(localized: "Sound.Shizuku", table: "NotificationSounds")
        case .hotaru: String(localized: "Sound.Hotaru", table: "NotificationSounds")
        case .kaeru: String(localized: "Sound.Kaeru", table: "NotificationSounds")
        case .suzumushi: String(localized: "Sound.Suzumushi", table: "NotificationSounds")
        case .momiji: String(localized: "Sound.Momiji", table: "NotificationSounds")
        case .take: String(localized: "Sound.Take", table: "NotificationSounds")
        case .mejiro: String(localized: "Sound.Mejiro", table: "NotificationSounds")
        case .kiri: String(localized: "Sound.Kiri", table: "NotificationSounds")
        case .hamon: String(localized: "Sound.Hamon", table: "NotificationSounds")
        case .rin: String(localized: "Sound.Rin", table: "NotificationSounds")
        }
    }
}
