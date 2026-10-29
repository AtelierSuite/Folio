import Foundation

public enum SleepStage: String, Sendable, Hashable, CaseIterable {
    case inBed
    case asleep
    case core
    case deep
    case rem
    case awake

    public var isAsleep: Bool {
        switch self {
        case .asleep, .core, .deep, .rem: true
        case .inBed, .awake: false
        }
    }
}
