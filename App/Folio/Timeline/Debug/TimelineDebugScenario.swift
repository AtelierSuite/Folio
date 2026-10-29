#if DEBUG
import Foundation

enum TimelineDebugScenario: String, CaseIterable, Identifiable {
    case thisWeek
    case fallBack
    case springForward

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .thisWeek: String(localized: "Debug.Scenario.ThisWeek", table: "Timeline")
        case .fallBack: String(localized: "Debug.Scenario.FallBack", table: "Timeline")
        case .springForward: String(localized: "Debug.Scenario.SpringForward", table: "Timeline")
        }
    }

    var calendar: Calendar {
        var calendar = Calendar.current
        if self != .thisWeek, let newYork = TimeZone(identifier: "America/New_York") {
            calendar.timeZone = newYork
        }
        return calendar
    }

    /// Both DST weeks end on the Sunday the clocks change in New York.
    var weekStart: Date {
        let calendar = calendar
        switch self {
        case .thisWeek:
            return calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? calendar.startOfDay(for: .now)
        case .fallBack:
            return calendar.date(from: DateComponents(year: 2026, month: 10, day: 26)) ?? .now
        case .springForward:
            return calendar.date(from: DateComponents(year: 2026, month: 3, day: 2)) ?? .now
        }
    }
}
#endif
