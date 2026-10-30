import Planner
import SwiftUI

struct ReminderListDetailView: View {
    @Environment(CalendarStore.self) private var store
    @Environment(SystemTimeObserver.self) private var systemTime
    let list: PlannerCalendar
    @State private var reminders: [ReminderItem] = []
    @State private var hasLoaded = false
    @State private var openedReminder: ReminderItem?
    @State private var isComposing = false

    var body: some View {
        content
            .navigationTitle(list.title)
            .toolbar {
                if !list.isReadOnly {
                    ToolbarItem(placement: .primaryAction) {
                        Button(String(localized: "NewReminder", table: "Lists"), systemImage: "plus") {
                            isComposing = true
                        }
                        .accessibilityIdentifier("ReminderListNewReminder")
                    }
                }
            }
            .sheet(item: $openedReminder) { reminder in
                ReminderEditorView(reminder: reminder)
            }
            .sheet(isPresented: $isComposing) {
                ReminderEditorView(initialDate: nil, listIdentifier: list.id)
            }
            .task(id: LoadKey(revision: store.contentRevision, calendar: systemTime.calendar)) {
                reminders = await store.reminders(inList: list.id, calendar: systemTime.calendar)
                hasLoaded = true
            }
    }

    @ViewBuilder
    private var content: some View {
        if hasLoaded && reminders.isEmpty {
            ContentUnavailableView(
                String(localized: "List.Empty.Title", table: "Lists"),
                systemImage: "checkmark.circle",
                description: Text(String(localized: "List.Empty.Description", table: "Lists"))
            )
        } else {
            List(reminders) { reminder in
                AgendaReminderRow(reminder: reminder, showsDueDay: true) { openedReminder = reminder }
            }
        }
    }

    private struct LoadKey: Equatable {
        let revision: Int
        let calendar: Calendar
    }
}
