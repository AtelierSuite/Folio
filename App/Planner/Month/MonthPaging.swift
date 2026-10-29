import Foundation

public struct MonthPaging: Sendable, Equatable {
    public let calendar: Calendar

    public init(calendar: Calendar) {
        self.calendar = calendar
    }

    public func monthStart(containing date: Date) -> Date {
        MonthGrid.monthInterval(containing: date, calendar: calendar).start
    }

    public func months(around date: Date, radius: Int) -> [Date] {
        let anchor = MonthGrid.noon(of: monthStart(containing: date), calendar: calendar)
        return (-radius...radius).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: anchor).map(monthStart(containing:))
        }
    }

    public func isSameMonth(_ lhs: Date, _ rhs: Date) -> Bool {
        monthStart(containing: lhs) == monthStart(containing: rhs)
    }

    /// Moves `date` into the month that starts at `month`, keeping its day of the month
    /// (clamped to the month's last day).
    public func date(_ date: Date, movedToMonthOf month: Date) -> Date {
        let months = calendar.dateComponents(
            [.month], from: monthStart(containing: date), to: monthStart(containing: month)
        ).month ?? 0
        let moved = calendar.date(byAdding: .month, value: months, to: MonthGrid.noon(of: date, calendar: calendar))
        return calendar.startOfDay(for: moved ?? month)
    }
}
