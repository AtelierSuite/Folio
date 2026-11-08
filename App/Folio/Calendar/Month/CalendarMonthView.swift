import Planner
import SwiftUI

struct CalendarMonthView: View {
    @Environment(CalendarNavigation.self) private var navigation
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("Calendar.ViewMode") private var mode: CalendarViewMode = .day
    @State private var months: [Date] = []
    @State private var position = ScrollPosition(idType: Date.self)
    @State private var scrollPhase = ScrollPhase.idle
    @State private var pageSize = CGSize.zero
    @State private var displayedWeekCount = 5

    private static let window = SlidingPageWindow(radius: 24)

    private var paging: MonthPaging {
        MonthPaging(calendar: navigation.calendar)
    }

    private var visibleMonth: Date? {
        position.viewID(type: Date.self)
    }

    var body: some View {
        ScrollView(.horizontal) {
            if pageSize != .zero {
                CalendarMonthPageStack(
                    months: months,
                    pageSize: pageSize,
                    displayedWeekCount: displayedWeekCount,
                    calendar: navigation.calendar
                ) { day in
                    navigation.show(day.date)
                    mode = .day
                }
            }
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        .scrollPosition($position)
        .scrollIndicators(.hidden)
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .onGeometryChange(for: CGSize.self) { $0.size } action: { size in
            pageSize = size
            scrollToSelectedMonthAfterRebuild()
        }
        .onScrollPhaseChange { _, phase in
            scrollPhase = phase
            guard phase == .idle else { return }
            selectVisibleMonth()
            recenterIfNeeded()
            fitRowsToVisibleMonth(animated: true)
        }
        .onAppear(perform: recenter)
        .onChange(of: navigation.selectedDate) {
            showSelectedMonth()
        }
        .onChange(of: visibleMonth) {
            if scrollPhase == .interacting || scrollPhase == .decelerating {
                selectVisibleMonth()
            } else if scrollPhase == .idle {
                fitRowsToVisibleMonth(animated: true)
            }
        }
        .onChange(of: navigation.calendar) {
            recenter()
        }
    }

    private func recenter() {
        months = paging.months(around: navigation.selectedDate, radius: Self.window.radius)
        position.scrollTo(id: paging.monthStart(containing: navigation.selectedDate))
        fitRowsToVisibleMonth(animated: false)
    }

    /// The page stack is rebuilt for every new size, and the rebuilt lazy stack does not reliably
    /// restore the old position: the first scroll can then land on a month years away.
    private func scrollToSelectedMonthAfterRebuild() {
        position.scrollTo(id: paging.monthStart(containing: navigation.selectedDate))
    }

    private func fitRowsToVisibleMonth(animated: Bool) {
        guard let visibleMonth else { return }
        let weekCount = MonthGrid(containing: visibleMonth, calendar: navigation.calendar).weeks.count
        guard weekCount != displayedWeekCount else { return }
        withAnimation(animated && !reduceMotion ? .snappy : nil) {
            displayedWeekCount = weekCount
        }
    }

    /// Slides the window of months once the scrolling has stopped; the month in view keeps its identity.
    private func recenterIfNeeded() {
        guard let visibleMonth else { return }
        let index = months.firstIndex(of: visibleMonth)
        guard index.map(Self.window.needsRecentering(atIndex:)) ?? true else { return }
        months = paging.months(around: visibleMonth, radius: Self.window.radius)
        position.scrollTo(id: visibleMonth)
    }

    private func showSelectedMonth() {
        let selectedMonth = paging.monthStart(containing: navigation.selectedDate)
        guard selectedMonth != visibleMonth, scrollPhase != .interacting else { return }
        guard months.contains(selectedMonth) else {
            recenter()
            return
        }
        withAnimation(reduceMotion ? nil : .default) {
            position.scrollTo(id: selectedMonth)
        }
    }

    private func selectVisibleMonth() {
        guard let visibleMonth, !paging.isSameMonth(visibleMonth, navigation.selectedDate) else { return }
        navigation.show(paging.date(navigation.selectedDate, movedToMonthOf: visibleMonth))
    }
}
