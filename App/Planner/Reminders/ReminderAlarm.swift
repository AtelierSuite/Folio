import Foundation

public enum ReminderAlarm: Sendable, Hashable {
    case relative(TimeInterval)
    case absolute(Date)

    public static let presetOffsets: [TimeInterval] = [0, -300, -900, -1800, -3600, -86400]

    public var isRelative: Bool {
        if case .relative = self { return true }
        return false
    }

    public func fireDate(dueDate: Date?) -> Date? {
        switch self {
        case .relative(let offset): dueDate?.addingTimeInterval(offset)
        case .absolute(let date): date
        }
    }
}
