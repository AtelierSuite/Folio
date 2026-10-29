import Foundation

extension WidgetSnapshot {
    /// The start of every day in `grid` that has at least one event.
    public func daysWithEvents(in grid: MonthGrid) -> Set<Date> {
        Set(grid.days.filter { day in events.contains { $0.overlaps(day.interval) } }.map(\.date))
    }
}
