import Foundation

enum LabClock {
    static let calendar = Calendar(identifier: .gregorian)
    static let today = calendar.date(from: DateComponents(year: 2026, month: 11, day: 6)) ?? .now
    static let defaultMinuteOfDay = 13 * 60 + 53

    static func date(dayOffset: Int = 0, hour: Int = 0, minute: Int = 0) -> Date {
        let day = calendar.date(byAdding: .day, value: dayOffset, to: today) ?? today
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }

    static func now(minuteOfDay: Int) -> Date {
        date(hour: minuteOfDay / 60, minute: minuteOfDay % 60)
    }
}
