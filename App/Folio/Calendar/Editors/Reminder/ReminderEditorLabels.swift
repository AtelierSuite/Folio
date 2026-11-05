import Foundation
import Planner

extension ReminderPriority {
    var title: String {
        switch self {
        case .none: String(localized: "Priority.None", table: "ReminderEditor")
        case .low: String(localized: "Priority.Low", table: "ReminderEditor")
        case .medium: String(localized: "Priority.Medium", table: "ReminderEditor")
        case .high: String(localized: "Priority.High", table: "ReminderEditor")
        }
    }
}

extension ReminderRecurrence.Frequency {
    var title: String {
        switch self {
        case .daily: String(localized: "Repeat.Daily", table: "ReminderEditor")
        case .weekly: String(localized: "Repeat.Weekly", table: "ReminderEditor")
        case .monthly: String(localized: "Repeat.Monthly", table: "ReminderEditor")
        case .yearly: String(localized: "Repeat.Yearly", table: "ReminderEditor")
        }
    }

    func intervalTitle(_ interval: Int) -> String {
        switch self {
        case .daily: String(localized: "Repeat.EveryDays \(interval)", table: "ReminderEditor")
        case .weekly: String(localized: "Repeat.EveryWeeks \(interval)", table: "ReminderEditor")
        case .monthly: String(localized: "Repeat.EveryMonths \(interval)", table: "ReminderEditor")
        case .yearly: String(localized: "Repeat.EveryYears \(interval)", table: "ReminderEditor")
        }
    }
}

extension ReminderAlarm {
    var title: String {
        switch self {
        case .relative(let offset) where offset == 0:
            return String(localized: "Alert.AtDueTime", table: "ReminderEditor")
        case .relative(let offset):
            let units: Set<Duration.UnitsFormatStyle.Unit> = spansWholeWeeks ? [.weeks] : [.days, .hours, .minutes]
            let duration = Duration.seconds(abs(offset)).formatted(.units(allowed: units, width: .wide))
            return offset < 0
                ? String(localized: "Alert.Before \(duration)", table: "ReminderEditor")
                : String(localized: "Alert.After \(duration)", table: "ReminderEditor")
        case .absolute(let date):
            return date.formatted(date: .abbreviated, time: .shortened)
        }
    }
}

extension ReminderEarlyAlert {
    var title: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = unit.formatterUnit
        formatter.unitsStyle = .full
        let duration = formatter.string(from: dateComponents) ?? ""
        return String(localized: "Alert.Before \(duration)", table: "ReminderEditor")
    }
}

private extension ReminderEarlyAlert.Unit {
    var formatterUnit: NSCalendar.Unit {
        switch self {
        case .minutes: .minute
        case .hours: .hour
        case .days: .day
        case .weeks: .weekOfMonth
        case .months: .month
        }
    }
}
