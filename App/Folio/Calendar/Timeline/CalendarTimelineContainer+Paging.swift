import Planner
import SwiftUI

/// Keeps the horizontal scroll position and `CalendarNavigation` in step: scrolling moves the
/// selected date (and with it the title), and the toolbar, Today and edge paging scroll the pages.
extension CalendarTimelineContainer {
    var columnsOnScreen: Int {
        requestedColumnsOnScreen ?? max(strip.daysPerPage, 1)
    }

    var scrolledPage: Date? {
        position.viewID(type: Date.self)
    }

    var scrollSync: some ViewModifier {
        TimelineScrollSyncModifier(
            selectedDate: navigation.selectedDate,
            scrolledPage: scrolledPage,
            stripKey: StripKey(unit: unit, columnsOnScreen: requestedColumnsOnScreen, calendar: navigation.calendar),
            onSelectedDateChange: scrollToSelectedDate,
            onScrolledPageChange: followScrollWhileScrolling,
            onStripKeyChange: rebuildStrip
        )
    }

    static func strip(
        unit: TimelineStrip.Unit, columnsOnScreen: Int?, around date: Date, calendar: Calendar
    ) -> TimelineStrip {
        let radius = unit == .day ? 21 * max(columnsOnScreen ?? 1, 1) : 8
        return TimelineStrip(unit: unit, around: date, window: SlidingPageWindow(radius: radius), calendar: calendar)
    }

    func handleScrollPhase(_ phase: ScrollPhase) {
        scrollPhase = phase
        guard phase == .idle else { return }
        followScroll()
        recenterIfNeeded()
        if let scrolledPage { settledPage = scrolledPage }
    }

    private func followScrollWhileScrolling() {
        guard scrollPhase == .interacting || scrollPhase == .decelerating else { return }
        followScroll()
    }

    private func followScroll() {
        guard let scrolledPage else { return }
        let date = strip.date(navigation.selectedDate, movedToPage: scrolledPage)
        if date != navigation.selectedDate {
            navigation.show(date)
        }
    }

    private func scrollToSelectedDate() {
        let target = strip.pageStart(containing: navigation.selectedDate)
        guard target != scrolledPage, scrollPhase != .interacting else { return }
        guard strip.index(ofPage: target) != nil else {
            strip = strip.recentered(on: target)
            relayout()
            position.scrollTo(id: target, anchor: .leading)
            settledPage = target
            return
        }
        withAnimation(reduceMotion ? nil : .snappy) {
            position.scrollTo(id: target, anchor: .leading)
        }
        if reduceMotion { settledPage = target }
    }

    /// Slides the window while nothing is moving. The page in view keeps its identity, so it stays put.
    private func recenterIfNeeded() {
        guard let scrolledPage, strip.needsRecentering(on: scrolledPage) else { return }
        strip = strip.recentered(on: scrolledPage)
        relayout()
        position.scrollTo(id: scrolledPage, anchor: .leading)
    }

    private func rebuildStrip() {
        let date = navigation.selectedDate
        strip = Self.strip(
            unit: unit, columnsOnScreen: requestedColumnsOnScreen, around: date, calendar: navigation.calendar
        )
        relayout()
        let page = strip.pageStart(containing: date)
        position.scrollTo(id: page, anchor: .leading)
        settledPage = page
    }
}

struct StripKey: Equatable {
    let unit: TimelineStrip.Unit
    let columnsOnScreen: Int?
    let calendar: Calendar
}

struct TimelineScrollSyncModifier: ViewModifier {
    let selectedDate: Date
    let scrolledPage: Date?
    let stripKey: StripKey
    let onSelectedDateChange: () -> Void
    let onScrolledPageChange: () -> Void
    let onStripKeyChange: () -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: selectedDate) { onSelectedDateChange() }
            .onChange(of: scrolledPage) { onScrolledPageChange() }
            .onChange(of: stripKey) { onStripKeyChange() }
    }
}
