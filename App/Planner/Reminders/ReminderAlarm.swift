import Foundation

public enum ReminderAlarm: Sendable, Hashable {
    case relative(TimeInterval)
    case absolute(Date)

    public static let weekOffset: TimeInterval = -604_800
    public static let presetOffsets: [TimeInterval] = [0, -300, -900, -1800, -3600, -86400, weekOffset]

    public var isRelative: Bool {
        if case .relative = self { return true }
        return false
    }

    public var spansWholeWeeks: Bool {
        guard case .relative(let offset) = self, offset != 0 else { return false }
        return offset.truncatingRemainder(dividingBy: Self.weekOffset) == 0
    }

    public func fireDate(dueDate: Date?) -> Date? {
        switch self {
        case .relative(let offset): dueDate?.addingTimeInterval(offset)
        case .absolute(let date): date
        }
    }
}
