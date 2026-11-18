import Foundation
import Planner

extension AlarmSound {
    var title: String {
        switch self {
        case .system: String(localized: "Sound.System", table: "AlarmSounds")
        case .yoake: String(localized: "Sound.Yoake", table: "AlarmSounds")
        case .komorebi: String(localized: "Sound.Komorebi", table: "AlarmSounds")
        case .hibari: String(localized: "Sound.Hibari", table: "AlarmSounds")
        case .shiokaze: String(localized: "Sound.Shiokaze", table: "AlarmSounds")
        case .hibiki: String(localized: "Sound.Hibiki", table: "AlarmSounds")
        case .hidamari: String(localized: "Sound.Hidamari", table: "AlarmSounds")
        case .tsubame: String(localized: "Sound.Tsubame", table: "AlarmSounds")
        case .arashi: String(localized: "Sound.Arashi", table: "AlarmSounds")
        case .hayate: String(localized: "Sound.Hayate", table: "AlarmSounds")
        case .kaminari: String(localized: "Sound.Kaminari", table: "AlarmSounds")
        }
    }
}
