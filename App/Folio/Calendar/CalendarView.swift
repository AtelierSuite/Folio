import SwiftUI

struct CalendarView: View {
    @AppStorage("Calendar.ViewMode") private var mode: CalendarViewMode = .day
    @State private var navigation = CalendarNavigation()
    @State private var composer: CalendarComposer?

    var body: some View {
        NavigationStack {
            content
                .calendarPermissionGate()
                .navigationTitle(navigation.selectedDate.formatted(.dateTime.year().month(.wide)))
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    CalendarToolbar(mode: $mode, composer: $composer, navigation: navigation)
                }
                .sheet(item: $composer) { composer in
                    switch composer {
                    case .newEvent: EventEditorView(initialDate: navigation.selectedDate)
                    case .newReminder: ReminderEditorView(initialDate: navigation.selectedDate)
                    }
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
