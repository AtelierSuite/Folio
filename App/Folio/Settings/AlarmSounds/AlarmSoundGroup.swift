import Foundation
import Planner

enum AlarmSoundGroup: CaseIterable, Identifiable {
    case gentle
    case steady
    case urgent

    var id: Self { self }

    var title: String {
        switch self {
        case .gentle: String(localized: "Group.Gentle", table: "AlarmSounds")
        case .steady: String(localized: "Group.Steady", table: "AlarmSounds")
        case .urgent: String(localized: "Group.Urgent", table: "AlarmSounds")
        }
    }

    var sounds: [AlarmSound] {
        switch self {
        case .gentle: [.yoake, .komorebi, .hibari]
        case .steady: [.shiokaze, .hidamari, .hibiki, .tsubame]
        case .urgent: [.arashi, .hayate, .kaminari]
        }
    }
}
