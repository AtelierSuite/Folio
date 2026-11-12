import Foundation

public struct FlexTimeDayClassifier: Sendable {
    public var workdays: Set<Int>
    public var holidays: Set<HolidayDay>

    public init(workdays: Set<Int>, holidays: Set<HolidayDay> = []) {
        self.workdays = workdays
        self.holidays = holidays
    }

    /// A public holiday on a work day doesn't count as a weekday, while one on a weekend counts as both.
    public func kinds(of date: Date, calendar: Calendar) -> Set<FlexTimeDayKind> {
        let isHoliday = holidays.contains(HolidayDay(date: date, timeZone: calendar.timeZone))
        let isWorkday = workdays.contains(calendar.component(.weekday, from: date))
        var kinds: Set<FlexTimeDayKind> = []
        if isHoliday {
            kinds.insert(.publicHoliday)
        }
        if !isWorkday {
            kinds.insert(.weekend)
        } else if !isHoliday {
            kinds.insert(.weekday)
        }
        return kinds
    }
}
