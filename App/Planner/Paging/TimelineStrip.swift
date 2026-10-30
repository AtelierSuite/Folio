import Foundation

/// The pages a timeline scrolls through: a sliding window of days or weeks laid end to end.
/// `days` holds every column of every page, so one layout covers the whole strip.
public struct TimelineStrip: Sendable, Equatable {
    public enum Unit: Sendable, Hashable {
        case day
        /// A week of `workdays` (weekday numbers), or all seven days when it's `nil`.
        case week(workdays: Set<Int>?)
    }

    public let unit: Unit
    public let calendar: Calendar
    public let window: SlidingPageWindow
    public let pages: [Date]
    public let days: TimelineDays
    public let daysPerPage: Int

    public init(unit: Unit, around date: Date, window: SlidingPageWindow, calendar: Calendar) {
        self.unit = unit
        self.calendar = calendar
        self.window = window
        let paging = Paging(unit: unit, calendar: calendar)
        let center = paging.pageStart(containing: date)
        let pages = window.offsets.map { paging.page(center, movedBy: $0) }
        let pageDates = pages.map(paging.dates(onPage:))
        self.pages = pages
        daysPerPage = pageDates.first?.count ?? 0
        days = TimelineDays(dates: pageDates.flatMap(\.self), calendar: calendar)
    }

    public func recentered(on date: Date) -> TimelineStrip {
        TimelineStrip(unit: unit, around: date, window: window, calendar: calendar)
    }

    public func pageStart(containing date: Date) -> Date {
        Paging(unit: unit, calendar: calendar).pageStart(containing: date)
    }

    public func index(ofPage page: Date) -> Int? {
        pages.firstIndex(of: page)
    }

    public func dayRange(ofPageAt index: Int) -> Range<Int> {
        let lowerBound = min(max(index, 0), pages.count) * daysPerPage
        return lowerBound..<min(lowerBound + daysPerPage, days.count)
    }

    /// True when `page` is missing or far enough from the centre that the window should slide.
    public func needsRecentering(on page: Date) -> Bool {
        guard let index = index(ofPage: page) else { return true }
        return window.needsRecentering(atIndex: index)
    }

    /// The days of the pages within `pageRadius` of `page`, for loading things that only matter near the screen.
    public func intervals(aroundPage page: Date, pageRadius: Int) -> [DateInterval] {
        guard let index = index(ofPage: page) else { return [] }
        let first = dayRange(ofPageAt: max(index - pageRadius, 0)).lowerBound
        let last = dayRange(ofPageAt: min(index + pageRadius, pages.count - 1)).upperBound
        return Array(days.intervals[first..<max(first, last)])
    }

    /// `date` carried onto `page`. Weeks keep the day of the week, as the week paging buttons do.
    public func date(_ date: Date, movedToPage page: Date) -> Date {
        switch unit {
        case .day:
            return page
        case .week:
            let paging = Paging(unit: unit, calendar: calendar)
            let weeks = calendar.dateComponents(
                [.weekOfYear], from: paging.pageStart(containing: date), to: page
            ).weekOfYear ?? 0
            let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date) ?? date
            let moved = calendar.date(byAdding: .weekOfYear, value: weeks, to: noon) ?? page
            return calendar.startOfDay(for: moved)
        }
    }
}

extension TimelineStrip {
    private struct Paging {
        let unit: Unit
        let calendar: Calendar

        func pageStart(containing date: Date) -> Date {
            switch unit {
            case .day: calendar.startOfDay(for: date)
            case .week: calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? calendar.startOfDay(for: date)
            }
        }

        func page(_ page: Date, movedBy offset: Int) -> Date {
            let component: Calendar.Component = unit == .day ? .day : .weekOfYear
            let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: page) ?? page
            return pageStart(containing: calendar.date(byAdding: component, value: offset, to: noon) ?? noon)
        }

        func dates(onPage page: Date) -> [Date] {
            switch unit {
            case .day:
                return [page]
            case .week(let workdays):
                let week = calendar.weekDates(containing: page)
                guard let workdays else { return week }
                let shown = week.filter { workdays.contains(calendar.component(.weekday, from: $0)) }
                return shown.isEmpty ? week : shown
            }
        }
    }
}
