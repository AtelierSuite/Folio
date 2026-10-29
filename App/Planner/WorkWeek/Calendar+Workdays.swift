import Foundation

extension Calendar {
    public static let weekdays = 1...7
    public static let fallbackWorkdays: Set<Int> = [2, 3, 4, 5, 6]

    /// Weekdays in display order, starting from the calendar's first weekday.
    public var orderedWeekdays: [Int] {
        Self.weekdays.map { offset in (firstWeekday - 1 + offset - 1) % 7 + 1 }
    }

    /// Work days derived from the weekend of the calendar's locale (Sun–Thu where the weekend is Fri–Sat).
    public var localeWorkdays: Set<Int> {
        let reference = date(from: DateComponents(year: 2026, month: 1, day: 5, hour: 12)) ?? .now
        let workdays = Self.weekdays.compactMap { offset -> Int? in
            guard let day = date(byAdding: .day, value: offset - 1, to: reference),
                  !isDateInWeekend(day) else { return nil }
            return component(.weekday, from: day)
        }
        return workdays.isEmpty ? Self.fallbackWorkdays : Set(workdays)
    }

    public func weekDates(containing date: Date) -> [Date] {
        let weekStart = dateInterval(of: .weekOfYear, for: date)?.start ?? startOfDay(for: date)
        let weekStartNoon = self.date(bySettingHour: 12, minute: 0, second: 0, of: weekStart) ?? weekStart
        return (0..<7).compactMap { offset in
            self.date(byAdding: .day, value: offset, to: weekStartNoon).map { startOfDay(for: $0) }
        }
    }

    public func workdayDates(inWeekContaining date: Date, workdays: Set<Int>) -> [Date] {
        weekDates(containing: date).filter { workdays.contains(component(.weekday, from: $0)) }
    }
}
