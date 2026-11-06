import Planner
import SwiftUI

struct CalendarWeekDayRow: View {
    @Environment(CalendarNavigation.self) private var navigation
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let workdays: Set<Int>?
    @State private var strip: TimelineStrip
    @State private var visibleWeek: Date?
    @State private var scrollPhase = ScrollPhase.idle
    @State private var viewportWidth: CGFloat = 0

    private static let window = SlidingPageWindow(radius: 8)

    init(workdays: Set<Int>?, initialDate: Date, calendar: Calendar) {
        self.workdays = workdays
        let strip = TimelineStrip(
            unit: .week(workdays: workdays), around: initialDate, window: Self.window, calendar: calendar
        )
        _strip = State(initialValue: strip)
        _visibleWeek = State(initialValue: strip.pageStart(containing: initialDate))
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
        .scrollPosition(id: $visibleWeek)
        .scrollIndicators(.hidden)
        .fixedSize(horizontal: false, vertical: true)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { viewportWidth = $0 }
        .onScrollPhaseChange { _, phase in
            scrollPhase = phase
            guard phase == .idle else { return }
            selectVisibleWeek()
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
        guard strip.index(ofPage: selectedWeek) != nil else {
            strip = strip.recentered(on: selectedWeek)
            visibleWeek = selectedWeek
            return
        }
        withAnimation(reduceMotion ? nil : .snappy) {
            visibleWeek = selectedWeek
        }
    }

    /// Slides the window once the scrolling has stopped; the week in view keeps its identity.
    private func recenterIfNeeded() {
        guard let visibleWeek, strip.needsRecentering(on: visibleWeek) else { return }
        strip = strip.recentered(on: visibleWeek)
        self.visibleWeek = visibleWeek
    }

    private func rebuildStrip() {
        strip = TimelineStrip(
            unit: .week(workdays: workdays),
            around: navigation.selectedDate,
            window: Self.window,
            calendar: navigation.calendar
        )
        visibleWeek = strip.pageStart(containing: navigation.selectedDate)
    }
}
