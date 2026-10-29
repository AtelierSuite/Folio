import Foundation
import Planner

enum SearchDateFilter: Hashable {
    case preset(SearchDatePreset)
    case custom(DateInterval)

    func interval(around date: Date, calendar: Calendar = .current) -> DateInterval {
        switch self {
        case .preset(let preset): preset.interval(around: date, calendar: calendar)
        case .custom(let interval): interval
        }
    }

    var title: String {
        switch self {
        case .preset(let preset):
            preset.title
        case .custom(let interval):
            (interval.start..<interval.end.addingTimeInterval(-1)).formatted(.interval.month(.abbreviated).day())
        }
    }

    static func custom(from startDay: Date, through endDay: Date, calendar: Calendar = .current) -> SearchDateFilter {
        let start = calendar.startOfDay(for: min(startDay, endDay))
        let lastDay = calendar.startOfDay(for: max(startDay, endDay))
        let end = calendar.date(byAdding: .day, value: 1, to: lastDay) ?? lastDay
        return .custom(DateInterval(start: start, end: end))
    }
}
