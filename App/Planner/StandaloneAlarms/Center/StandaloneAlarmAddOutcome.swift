import Foundation

public enum StandaloneAlarmAddOutcome: Sendable, Equatable {
    case scheduled
    case denied
    case pastDate
    case failed
}
