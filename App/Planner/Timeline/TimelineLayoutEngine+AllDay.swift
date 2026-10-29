import Foundation

extension TimelineLayoutEngine {
    private struct VisibleAllDayEntry {
        let entry: TimelineEntry
        let interval: DateInterval
        let days: TimelineLaneSolver.Item
    }

    func allDayPlacements(for entries: [(entry: TimelineEntry, interval: DateInterval)]) -> [TimelineAllDayPlacement] {
        let visibleEntries = entries.compactMap { entry, interval -> VisibleAllDayEntry? in
            guard let firstDayIndex = days.intervals.firstIndex(where: { $0.end > interval.start }),
                  let lastDayIndex = days.intervals.lastIndex(where: { $0.start < interval.end }),
                  firstDayIndex <= lastDayIndex else { return nil }
            let dayRange = TimelineLaneSolver.Item(firstDayIndex: firstDayIndex, lastDayIndex: lastDayIndex)
            return VisibleAllDayEntry(entry: entry, interval: interval, days: dayRange)
        }
        let lanes = TimelineLaneSolver.lanes(for: visibleEntries.map(\.days))
        return zip(visibleEntries, lanes).map { visibleEntry, lane in
            let firstDay = days.intervals[visibleEntry.days.firstDayIndex]
            let lastDay = days.intervals[visibleEntry.days.lastDayIndex]
            return TimelineAllDayPlacement(
                entry: visibleEntry.entry,
                firstDayIndex: visibleEntry.days.firstDayIndex,
                lastDayIndex: visibleEntry.days.lastDayIndex,
                lane: lane,
                continuesFromBefore: visibleEntry.interval.start < firstDay.start,
                continuesAfter: visibleEntry.interval.end > lastDay.end
            )
        }
        .sorted { ($0.lane, $0.firstDayIndex) < ($1.lane, $1.firstDayIndex) }
    }
}
