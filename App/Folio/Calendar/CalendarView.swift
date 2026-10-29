import SwiftUI

struct CalendarView: View {
    @AppStorage("Calendar.ViewMode") private var mode: CalendarViewMode = .day
    @State private var navigation = CalendarNavigation()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(navigation.selectedDate.formatted(.dateTime.year().month(.wide)))
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    CalendarToolbar(mode: $mode, navigation: navigation)
                }
        }
        .environment(navigation)
    }

    @ViewBuilder
    private var content: some View {
        switch mode {
        case .list: AgendaView()
        case .day: CalendarDayView()
        case .multiDay: CalendarMultiDayView()
        case .workWeek: CalendarWeekView(isWorkWeek: true)
        case .week: CalendarWeekView(isWorkWeek: false)
        case .month: CalendarMonthView()
        }
    }
}
