import Planner
import SwiftUI

struct AgendaView: View {
    @Environment(CalendarStore.self) private var store
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
                    AgendaDaySection(day: day) { openedReminder = $0 }
                }
            }
        }
        .sheet(item: $openedReminder) { reminder in
            ReminderEditorView(reminder: reminder)
        }
        .task(id: store.contentRevision) {
            await load()
        }
    }

    private func load() async {
        let interval = AgendaDay.upcomingInterval(dayCount: Self.dayCount)
        async let events = store.events(in: interval)
        async let reminders = store.reminders(in: interval)
        days = await AgendaDay.days(in: interval, events: events, reminders: reminders)
        hasLoaded = true
    }
}
