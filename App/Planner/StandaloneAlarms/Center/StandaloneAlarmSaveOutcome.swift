import Foundation

public enum StandaloneAlarmSaveOutcome: Sendable, Equatable {
    case scheduled
    case denied
    case pastDate
    case failed
}
