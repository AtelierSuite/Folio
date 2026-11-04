import Planner
import SwiftUI

struct CalendarView: View {
    @Environment(CalendarStore.self) var store
    @Environment(SystemTimeObserver.self) private var systemTime
    @AppStorage("Calendar.ViewMode") var mode: CalendarViewMode = .day
    @State var navigation = CalendarNavigation()
    @State var composer: CalendarComposer?
    @State var itemRequest: CalendarItemRequest?
    @State var isShowingInbox = false
    @State private var invitationCounts = InvitationCounts()

    var body: some View {
        NavigationStack {
            content
                .calendarCreationMenu(calendar: navigation.calendar)
                .calendarPermissionGate()
                .navigationTitle(navigation.selectedDate.formatted(.dateTime.year().month(.wide)))
                .alternateCalendarSubtitle(for: navigation.selectedDate, in: navigation.calendar)
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    CalendarToolbar(
                        mode: $mode,
                        composer: $composer,
                        isShowingInbox: $isShowingInbox,
                        navigation: navigation,
                        invitationCounts: invitationCounts
                    )
                }
                .sheet(item: $composer) { composer in
                    switch composer {
                    case .newEvent: EventEditorView(initialDate: navigation.selectedDate)
                    case .newReminder: ReminderEditorView(initialDate: navigation.selectedDate)
                    case .newAlarm: StandaloneAlarmComposerView(initialDate: StandaloneAlarm.suggestedFireDate(
                        at: navigation.selectedDate, hasTime: false, now: .now, calendar: navigation.calendar
                    ))
                    }
                }
        }
        .inspector(isPresented: $isShowingInbox) {
            ReminderInboxView(isPresented: $isShowingInbox)
                .inspectorColumnWidth(min: 260, ideal: 320, max: 420)
        }
        .calendarItemSheet(request: $itemRequest)
        .providesAlternateCalendar()
        .providesDayHighlights()
        .environment(navigation)
        .loadsInvitationCounts(into: $invitationCounts, from: store)
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
