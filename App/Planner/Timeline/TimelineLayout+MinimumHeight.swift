import Foundation

extension TimelineLayout {
    /// Zoomed out, cards keep a minimum height on screen that can be taller than a short entry's
    /// duration. Solving the columns again with that height keeps those cards from covering the
    /// entries right after them.
    public func fittingCards(minimumHours: Double) -> TimelineLayout {
        guard timedPlacements.contains(where: { $0.endHour - $0.startHour < minimumHours }) else { return self }
        let timed = Dictionary(grouping: timedPlacements, by: \.dayIndex)
            .sorted { $0.key < $1.key }
            .flatMap { _, placements in
                let items = placements.map {
                    TimelineColumnSolver.Item(start: $0.startHour, end: max($0.endHour, $0.startHour + minimumHours))
                }
                return zip(placements, TimelineColumnSolver.assignments(for: items))
                    .map { $0.reassigned(to: $1) }
                    .sorted { ($0.startHour, $0.column) < ($1.startHour, $1.column) }
            }
        return TimelineLayout(days: days, timedPlacements: timed, allDayPlacements: allDayPlacements)
    }
}

extension TimelineTimedPlacement {
    fileprivate func reassigned(to assignment: TimelineColumnSolver.Assignment) -> TimelineTimedPlacement {
        TimelineTimedPlacement(
            entry: entry,
            interval: interval,
            dayIndex: dayIndex,
            startHour: startHour,
            endHour: endHour,
            column: assignment.column,
            columnSpan: assignment.columnSpan,
            columnCount: assignment.columnCount,
            continuesFromPreviousDay: continuesFromPreviousDay,
            continuesToNextDay: continuesToNextDay
        )
    }
}
