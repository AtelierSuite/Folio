import Foundation

extension TimelineLayout {
    /// The part of the layout on `dayRange`, with day indices counted from its first day. Timed
    /// columns are solved per day, so they carry over as they are; all-day lanes are packed again
    /// so a page doesn't keep empty lanes left by items on other pages.
    public func page(_ dayRange: Range<Int>) -> TimelineLayout {
        let range = dayRange.clamped(to: 0..<days.count)
        let pageDays = TimelineDays(intervals: Array(days.intervals[range]), calendar: days.calendar)
        let timed = timedPlacements
            .filter { range.contains($0.dayIndex) }
            .map { $0.movedToDay($0.dayIndex - range.lowerBound) }
        let shownAllDay = allDayPlacements.filter {
            $0.firstDayIndex < range.upperBound && $0.lastDayIndex >= range.lowerBound
        }
        let clipped = shownAllDay.map { placement in
            TimelineLaneSolver.Item(
                firstDayIndex: max(placement.firstDayIndex, range.lowerBound) - range.lowerBound,
                lastDayIndex: min(placement.lastDayIndex, range.upperBound - 1) - range.lowerBound
            )
        }
        let lanes = TimelineLaneSolver.lanes(for: clipped)
        let allDay = zip(shownAllDay, zip(clipped, lanes)).map { placement, clippedLane in
            let (item, lane) = clippedLane
            return TimelineAllDayPlacement(
                entry: placement.entry,
                firstDayIndex: item.firstDayIndex,
                lastDayIndex: item.lastDayIndex,
                lane: lane,
                continuesFromBefore: placement.continuesFromBefore || placement.firstDayIndex < range.lowerBound,
                continuesAfter: placement.continuesAfter || placement.lastDayIndex >= range.upperBound
            )
        }
        .sorted { ($0.lane, $0.firstDayIndex) < ($1.lane, $1.firstDayIndex) }
        return TimelineLayout(days: pageDays, timedPlacements: timed, allDayPlacements: allDay)
    }
}

extension TimelineTimedPlacement {
    fileprivate func movedToDay(_ newDayIndex: Int) -> TimelineTimedPlacement {
        TimelineTimedPlacement(
            entry: entry,
            interval: interval,
            dayIndex: newDayIndex,
            startHour: startHour,
            endHour: endHour,
            column: column,
            columnSpan: columnSpan,
            columnCount: columnCount,
            continuesFromPreviousDay: continuesFromPreviousDay,
            continuesToNextDay: continuesToNextDay
        )
    }
}
