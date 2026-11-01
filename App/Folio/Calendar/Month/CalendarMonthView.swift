import Planner
import SwiftUI

struct CalendarMonthView: View {
    @Environment(CalendarNavigation.self) private var navigation
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("Calendar.ViewMode") private var mode: CalendarViewMode = .day
    @State private var months: [Date] = []
    @State private var visibleMonth: Date?
    @State private var scrollPhase = ScrollPhase.idle
    @State private var pageSize = CGSize.zero
    @State private var displayedWeekCount = 5

    private static let window = SlidingPageWindow(radius: 24)

    private var paging: MonthPaging {
        MonthPaging(calendar: navigation.calendar)
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
        .scrollPosition(id: $visibleMonth)
        .scrollIndicators(.hidden)
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .onGeometryChange(for: CGSize.self) { $0.size } action: { pageSize = $0 }
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
        visibleMonth = paging.monthStart(containing: navigation.selectedDate)
        fitRowsToVisibleMonth(animated: false)
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
        self.visibleMonth = visibleMonth
    }

    private func showSelectedMonth() {
        let selectedMonth = paging.monthStart(containing: navigation.selectedDate)
        guard selectedMonth != visibleMonth, scrollPhase != .interacting else { return }
        guard months.contains(selectedMonth) else {
            recenter()
            return
        }
        withAnimation(reduceMotion ? nil : .default) {
            visibleMonth = selectedMonth
        }
    }

    private func selectVisibleMonth() {
        guard let visibleMonth, !paging.isSameMonth(visibleMonth, navigation.selectedDate) else { return }
        navigation.show(paging.date(navigation.selectedDate, movedToMonthOf: visibleMonth))
    }
}
