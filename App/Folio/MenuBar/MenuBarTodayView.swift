#if os(macOS)
import Planner
import SwiftUI

struct MenuBarTodayView: View {
    let agenda: MenuBarAgenda
    @Environment(CalendarStore.self) private var store
    @Environment(AppDestinationRequests.self) private var requests
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        let opener = MenuBarAppOpener(openWindow: openWindow, requests: requests)
        VStack(spacing: 0) {
            MenuBarTodayHeader(day: agenda.today) { opener.open(.calendarDay(agenda.today)) }
            Divider()
            if store.eventAuthorization.allowsReading || store.reminderAuthorization.allowsReading {
                MenuBarTodayTimeline(day: agenda.today, onOpen: opener.open)
                    .id(agenda.today)
            } else {
                MenuBarAccessRequiredView { opener.open() }
            }
        }
        .frame(width: 340, height: 520)
    }
}
#endif
