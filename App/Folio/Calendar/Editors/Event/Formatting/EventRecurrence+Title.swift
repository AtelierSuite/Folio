import Foundation
import Planner

extension EventRecurrence.Frequency {
    var title: String {
        switch self {
        case .daily: String(localized: "Recurrence.Daily", table: "EventEditor")
        case .weekly: String(localized: "Recurrence.Weekly", table: "EventEditor")
        case .monthly: String(localized: "Recurrence.Monthly", table: "EventEditor")
        case .yearly: String(localized: "Recurrence.Yearly", table: "EventEditor")
        }
    }

    func intervalTitle(_ interval: Int) -> String {
        switch self {
        case .daily: String(localized: "Recurrence.EveryDays \(interval)", table: "EventEditor")
        case .weekly: String(localized: "Recurrence.EveryWeeks \(interval)", table: "EventEditor")
        case .monthly: String(localized: "Recurrence.EveryMonths \(interval)", table: "EventEditor")
        case .yearly: String(localized: "Recurrence.EveryYears \(interval)", table: "EventEditor")
        }
    }
}

extension EventRecurrence {
    var summary: String {
        let repetition = interval == 1 ? frequency.title : frequency.intervalTitle(interval)
        switch end {
        case .never:
            return repetition
        case .onDate(let date):
            let formattedDate = date.formatted(date: .abbreviated, time: .omitted)
            return String(localized: "Recurrence.UntilDate \(repetition) \(formattedDate)", table: "EventEditor")
        case .afterOccurrences(let count):
            return String(localized: "Recurrence.Times \(repetition) \(count)", table: "EventEditor")
        }
    }
}
