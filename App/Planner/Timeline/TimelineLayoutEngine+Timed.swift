import Foundation

extension TimelineLayoutEngine {
    private struct TimedSegment {
        let entry: TimelineEntry
        let interval: DateInterval
        let segment: TimelineDaySegment
    }

    func timedPlacements(for entries: [(entry: TimelineEntry, interval: DateInterval)]) -> [TimelineTimedPlacement] {
        var segmentsByDay = [[TimedSegment]](repeating: [], count: days.count)
        for (entry, interval) in entries {
            for segment in days.segments(from: interval.start, to: interval.end) {
                let timedSegment = TimedSegment(entry: entry, interval: interval, segment: visible(segment))
                segmentsByDay[segment.dayIndex].append(timedSegment)
            }
        }
        return segmentsByDay.flatMap { daySegments in
            let items = daySegments.map {
                TimelineColumnSolver.Item(start: $0.segment.startHour, end: $0.segment.endHour)
            }
            let assignments = TimelineColumnSolver.assignments(for: items)
            return zip(daySegments, assignments).map { daySegment, assignment in
                TimelineTimedPlacement(
                    entry: daySegment.entry,
                    interval: daySegment.interval,
                    dayIndex: daySegment.segment.dayIndex,
                    startHour: daySegment.segment.startHour,
                    endHour: daySegment.segment.endHour,
                    column: assignment.column,
                    columnSpan: assignment.columnSpan,
                    columnCount: assignment.columnCount,
                    continuesFromPreviousDay: daySegment.segment.continuesFromPreviousDay,
                    continuesToNextDay: daySegment.segment.continuesToNextDay
                )
            }
            .sorted { ($0.startHour, $0.column) < ($1.startHour, $1.column) }
        }
    }

    private func visible(_ segment: TimelineDaySegment) -> TimelineDaySegment {
        let minimumHours = minimumEntryDuration / 3600
        guard segment.endHour - segment.startHour < minimumHours else { return segment }
        let endHour = min(TimelineDays.hoursPerDay, segment.startHour + minimumHours)
        return TimelineDaySegment(
            dayIndex: segment.dayIndex,
            startHour: max(0, endHour - minimumHours),
            endHour: endHour,
            continuesFromPreviousDay: segment.continuesFromPreviousDay,
            continuesToNextDay: segment.continuesToNextDay
        )
    }
}
