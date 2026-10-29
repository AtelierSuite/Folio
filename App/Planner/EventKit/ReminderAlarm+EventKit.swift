import EventKit

extension ReminderAlarm {
    init?(_ alarm: EKAlarm) {
        guard alarm.structuredLocation == nil, alarm.proximity == .none else { return nil }
        if let absoluteDate = alarm.absoluteDate {
            self = .absolute(absoluteDate)
        } else {
            self = .relative(alarm.relativeOffset)
        }
    }

    var eventKitAlarm: EKAlarm {
        switch self {
        case .relative(let offset): EKAlarm(relativeOffset: offset)
        case .absolute(let date): EKAlarm(absoluteDate: date)
        }
    }
}
