import Foundation

public enum SearchDatePreset: String, Sendable, Hashable, CaseIterable, Identifiable {
    case today
    case next7Days
    case next30Days
    case past7Days
    case past30Days

    public var id: Self { self }

    public func interval(around date: Date, calendar: Calendar = .current) -> DateInterval {
        let today = calendar.startOfDay(for: date)
        func day(_ offset: Int) -> Date {
            calendar.date(byAdding: .day, value: offset, to: today) ?? today
        }
        return switch self {
        case .today: DateInterval(start: today, end: day(1))
        case .next7Days: DateInterval(start: today, end: day(7))
        case .next30Days: DateInterval(start: today, end: day(30))
        case .past7Days: DateInterval(start: day(-6), end: day(1))
        case .past30Days: DateInterval(start: day(-29), end: day(1))
        }
    }
}
