import Planner
import SwiftUI

/// How the timeline's columns are grouped into horizontally scrolling pages.
struct TimelinePages: Equatable {
    var starts: [Date]
    var daysPerPage: Int
    var columnsOnScreen: Int
    var snapping: TimelineScrollSnapping

    func index(of page: Date) -> Int? {
        starts.firstIndex(of: page)
    }

    func dayRange(ofPageAt index: Int) -> Range<Int> {
        let lowerBound = index * daysPerPage
        return lowerBound..<(lowerBound + daysPerPage)
    }

    func dayRange(of page: Date) -> Range<Int>? {
        index(of: page).map(dayRange(ofPageAt:))
    }
}

extension TimelinePages {
    /// Day pages fling freely and settle on a day; week pages move a week at a time.
    init(strip: TimelineStrip, columnsOnScreen: Int) {
        let isWeek = strip.unit != .day
        self.init(
            starts: strip.pages,
            daysPerPage: strip.daysPerPage,
            columnsOnScreen: columnsOnScreen,
            snapping: TimelineScrollSnapping(
                columnsOnScreen: columnsOnScreen,
                columnsPerStep: isWeek ? strip.daysPerPage : 1,
                limitsToOneStep: isWeek
            )
        )
    }

    /// Every day on one page that fits the screen, so it doesn't scroll.
    init(single days: TimelineDays) {
        let first = days.intervals.first?.start ?? .distantPast
        self.init(
            starts: [first],
            daysPerPage: days.count,
            columnsOnScreen: max(days.count, 1),
            snapping: TimelineScrollSnapping(columnsOnScreen: max(days.count, 1))
        )
    }
}
