import Foundation

public enum CalendarAlarm: Sendable, Hashable {
    case relative(offset: TimeInterval)
    case absolute(date: Date)

    public func fireDate(relativeTo anchorDate: Date?) -> Date? {
        switch self {
        case .relative(let offset): anchorDate?.addingTimeInterval(offset)
        case .absolute(let date): date
        }
    }
}

extension CalendarAlarm {
    public init(_ alarm: ReminderAlarm) {
        switch alarm {
        case .relative(let offset): self = .relative(offset: offset)
        case .absolute(let date): self = .absolute(date: date)
        }
    }
}
