import Foundation

extension ReminderDraft {
    public mutating func setHasDueDate(_ hasDueDate: Bool, defaultDate: Date, calendar: Calendar = .current) {
        if hasDueDate {
            dueDate = dueDate ?? calendar.startOfDay(for: defaultDate)
        } else {
            dueDate = nil
            hasDueTime = false
            recurrence = nil
        }
    }

    public mutating func setHasDueTime(_ hasTime: Bool, now: Date = .now, calendar: Calendar = .current) {
        let day = calendar.startOfDay(for: dueDate ?? now)
        if hasTime {
            let nextHour = (calendar.component(.hour, from: now) + 1) % 24
            dueDate = calendar.date(bySettingHour: nextHour, minute: 0, second: 0, of: day) ?? day
        } else {
            dueDate = day
            alarms.removeAll(where: \.isRelative)
        }
        hasDueTime = hasTime
    }
}
