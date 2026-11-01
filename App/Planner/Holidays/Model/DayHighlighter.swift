import Foundation

public struct DayHighlighter: Equatable, Sendable {
    public static let none = DayHighlighter()

    public var weekendWeekdays: Set<Int>
    public var holidayNames: [HolidayDay: String]

    public init(weekendWeekdays: Set<Int> = [], holidays: [Holiday] = []) {
        self.weekendWeekdays = weekendWeekdays
        holidayNames = Dictionary(holidays.map { ($0.day, $0.name) }) { first, second in
            first == second ? first : "\(first), \(second)"
        }
    }

    public var isActive: Bool {
        !weekendWeekdays.isEmpty || !holidayNames.isEmpty
    }

    public func isWeekend(weekday: Int) -> Bool {
        weekendWeekdays.contains(weekday)
    }

    public func holidayName(on date: Date, calendar: Calendar) -> String? {
        guard !holidayNames.isEmpty else { return nil }
        return holidayNames[HolidayDay(date: date, timeZone: calendar.timeZone)]
    }

    public func isHighlighted(_ date: Date, calendar: Calendar) -> Bool {
        isWeekend(weekday: calendar.component(.weekday, from: date)) || holidayName(on: date, calendar: calendar) != nil
    }
}
