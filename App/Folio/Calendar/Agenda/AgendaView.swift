import Planner
import SwiftUI

struct AgendaView: View {
    @Environment(CalendarStore.self) private var store
    @Environment(SystemTimeObserver.self) private var systemTime
    @State private var days: [AgendaDay] = []
    @State private var hasLoaded = false
    @State private var openedReminder: ReminderItem?

    private static let dayCount = 7

    var body: some View {
        Group {
            if hasLoaded && days.allSatisfy(\.isEmpty) {
                ContentUnavailableView(
                    String(localized: "Empty.Title", table: "Agenda"),
                    systemImage: "calendar",
                    description: Text(String(localized: "Empty.Description", table: "Agenda"))
                )
            } else {
                List(days.filter { !$0.isEmpty }) { day in
                    AgendaDaySection(
                        day: day,
                        onOpenReminder: { openedReminder = $0 }
                    )
                }
            }
        }
        .sheet(item: $openedReminder) { reminder in
            ReminderEditorView(reminder: reminder)
        }
        .eventActionsHost(events: days.flatMap(\.events))
        .task(id: LoadKey(revision: store.contentRevision, calendar: systemTime.calendar)) {
            await load()
        }
    }

    private func load() async {
        let calendar = systemTime.calendar
        let interval = AgendaDay.upcomingInterval(dayCount: Self.dayCount, calendar: calendar)
        async let events = store.events(in: interval)
        async let reminders = store.reminders(in: interval, calendar: calendar)
        days = await AgendaDay.days(in: interval, events: events, reminders: reminders, calendar: calendar)
        hasLoaded = true
    }

    private struct LoadKey: Equatable {
        let revision: Int
        let calendar: Calendar
    }
}
