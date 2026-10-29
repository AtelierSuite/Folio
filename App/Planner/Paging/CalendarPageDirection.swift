import Foundation

public enum CalendarPageDirection: Sendable, Equatable {
    case backward
    case forward

    var sign: Int {
        switch self {
        case .backward: -1
        case .forward: 1
        }
    }
}
