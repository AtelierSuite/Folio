import Planner
import SwiftUI

struct CalendarView: View {
    @Environment(CalendarStore.self) var store
    @Environment(SystemTimeObserver.self) private var systemTime
    @AppStorage("Calendar.ViewMode") var mode: CalendarViewMode = .day
    @State var navigation = CalendarNavigation()
    @State var composer: CalendarComposer?
    @State var routedEvent: CalendarEvent?
    @State var isShowingInbox = false
    @State private var pendingInvitationCount = 0

    var body: some View {
        NavigationStack {
            content
                .calendarPermissionGate()
                .navigationTitle(navigation.selectedDate.formatted(.dateTime.year().month(.wide)))
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    CalendarToolbar(
                        mode: $mode,
                        composer: $composer,
                        isShowingInbox: $isShowingInbox,
                        navigation: navigation,
                        pendingInvitationCount: pendingInvitationCount
                    )
                }
                .inspector(isPresented: $isShowingInbox) {
                    ReminderInboxView(isPresented: $isShowingInbox)
                        .inspectorColumnWidth(min: 260, ideal: 320, max: 420)
                }
                .sheet(item: $composer) { composer in
                    switch composer {
                    case .newEvent: EventEditorView(initialDate: navigation.selectedDate)
                    case .newReminder: ReminderEditorView(initialDate: navigation.selectedDate)
                    }
                }
        }
        .environment(navigation)
        .eventDetailSheet(item: $routedEvent)
        .loadsPendingInvitationCount(into: $pendingInvitationCount, from: store)
        .handlesAppDestinations(show)
        .onChange(of: systemTime.calendar, initial: true) {
            navigation.adopt(systemTime.calendar)
        }
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
