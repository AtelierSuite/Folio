import EventKit

extension CalendarAlarm {
    init?(_ alarm: EKAlarm) {
        guard alarm.structuredLocation == nil, alarm.proximity == .none else { return nil }
        if let absoluteDate = alarm.absoluteDate {
            self = .absolute(date: absoluteDate)
        } else {
            self = .relative(offset: alarm.relativeOffset)
        }
    }

    static func alarms(of event: EKEvent) -> [CalendarAlarm] {
        (event.alarms ?? []).compactMap(CalendarAlarm.init)
    }
}
