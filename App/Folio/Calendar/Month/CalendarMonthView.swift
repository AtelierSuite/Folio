import Planner
import SwiftUI

struct CalendarMonthView: View {
    @Environment(CalendarNavigation.self) private var navigation
    @AppStorage("Calendar.ViewMode") private var mode: CalendarViewMode = .day
    @State private var months: [Date] = []
    @State private var visibleMonth: Date?

    private static let pagingRadius = 60

    private var paging: MonthPaging {
        MonthPaging(calendar: navigation.calendar)
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(months, id: \.self) { month in
                    CalendarMonthPageView(grid: MonthGrid(containing: month, calendar: navigation.calendar)) { day in
                        navigation.show(day.date)
                        mode = .day
                    }
                    .containerRelativeFrame([.horizontal, .vertical])
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $visibleMonth)
        .scrollIndicators(.hidden)
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .onAppear(perform: recenter)
        .onChange(of: navigation.selectedDate) {
            showSelectedMonth()
        }
        .onChange(of: visibleMonth) {
            selectVisibleMonth()
        }
        .onChange(of: navigation.calendar) {
            recenter()
        }
    }

    private func recenter() {
        months = paging.months(around: navigation.selectedDate, radius: Self.pagingRadius)
        visibleMonth = paging.monthStart(containing: navigation.selectedDate)
    }

    private func showSelectedMonth() {
        let selectedMonth = paging.monthStart(containing: navigation.selectedDate)
        guard selectedMonth != visibleMonth else { return }
        guard months.contains(selectedMonth) else {
            recenter()
            return
        }
        withAnimation {
            visibleMonth = selectedMonth
        }
    }

    private func selectVisibleMonth() {
        guard let visibleMonth, !paging.isSameMonth(visibleMonth, navigation.selectedDate) else { return }
        navigation.show(paging.date(navigation.selectedDate, movedToMonthOf: visibleMonth))
    }
}
