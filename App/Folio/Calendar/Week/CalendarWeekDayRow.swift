import Planner
import SwiftUI

struct CalendarWeekDayRow: View {
    @Environment(CalendarNavigation.self) private var navigation
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let workdays: Set<Int>?
    @State private var strip: TimelineStrip
    @State private var position: ScrollPosition
    @State private var anchoredWeek: Date
    @State private var scrollPhase = ScrollPhase.idle
    @State private var isScrolledByUser = false
    @State private var viewportWidth: CGFloat = 0

    private static let window = SlidingPageWindow(radius: 8)

    private var visibleWeek: Date? {
        position.viewID(type: Date.self)
    }

    init(workdays: Set<Int>?, initialDate: Date, calendar: Calendar) {
        self.workdays = workdays
        let strip = TimelineStrip(
            unit: .week(workdays: workdays), around: initialDate, window: Self.window, calendar: calendar
        )
        _strip = State(initialValue: strip)
        let week = strip.pageStart(containing: initialDate)
        _position = State(initialValue: ScrollPosition(id: week, anchor: .leading))
        _anchoredWeek = State(initialValue: week)
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(strip.pages, id: \.self) { week in
                    CalendarWeekDayRowPage(
                        dates: strip.calendar.shownDates(inWeekContaining: week, workdays: workdays),
                        selectedDate: strip.date(navigation.selectedDate, movedToPage: week),
                        calendar: strip.calendar,
                        onSelect: navigation.show
                    )
                    .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
            .id(viewportWidth)
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        .scrollPosition($position, anchor: .leading)
        .scrollIndicators(.hidden)
        .fixedSize(horizontal: false, vertical: true)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
            viewportWidth = width
            keepAnchoredWeek()
        }
        .onScrollPhaseChange { _, phase in
            scrollPhase = phase
            if phase == .interacting || phase == .decelerating { isScrolledByUser = true }
            guard phase == .idle else { return }
            if isScrolledByUser { selectVisibleWeek() }
            isScrolledByUser = false
            if let visibleWeek { anchoredWeek = visibleWeek }
            recenterIfNeeded()
        }
        .onChange(of: navigation.selectedDate) { showSelectedWeek() }
        .onChange(of: StripKey(unit: .week(workdays: workdays), columnsOnScreen: nil, calendar: navigation.calendar)) {
            rebuildStrip()
        }
    }

    private func selectVisibleWeek() {
        guard let visibleWeek else { return }
        let date = strip.date(navigation.selectedDate, movedToPage: visibleWeek)
        if date != navigation.selectedDate {
            navigation.show(date)
        }
    }

    private func showSelectedWeek() {
        let selectedWeek = strip.pageStart(containing: navigation.selectedDate)
        guard selectedWeek != visibleWeek, scrollPhase != .interacting else { return }
        anchoredWeek = selectedWeek
        guard strip.index(ofPage: selectedWeek) != nil else {
            strip = strip.recentered(on: selectedWeek)
            keepAnchoredWeek()
            return
        }
        withAnimation(reduceMotion ? nil : .snappy) {
            keepAnchoredWeek()
        }
    }

    /// Slides the window once the scrolling has stopped; the week in view keeps its identity.
    private func recenterIfNeeded() {
        guard let visibleWeek, strip.needsRecentering(on: visibleWeek) else { return }
        strip = strip.recentered(on: visibleWeek)
        keepAnchoredWeek()
    }

    /// The scroll view keeps its offset in points when it's resized, which would leave it between weeks.
    private func keepAnchoredWeek() {
        position.scrollTo(id: anchoredWeek, anchor: .leading)
    }

    private func rebuildStrip() {
        strip = TimelineStrip(
            unit: .week(workdays: workdays),
            around: navigation.selectedDate,
            window: Self.window,
            calendar: navigation.calendar
        )
        anchoredWeek = strip.pageStart(containing: navigation.selectedDate)
        keepAnchoredWeek()
    }
}
