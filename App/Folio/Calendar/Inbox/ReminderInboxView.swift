import Planner
import SwiftUI

/// Reminders without a due date, shown beside the calendar (or as a sheet on narrow screens).
struct ReminderInboxView: View {
    @Environment(CalendarStore.self) private var store
    @Environment(SystemTimeObserver.self) private var systemTime
    @Binding var isPresented: Bool
    @State private var reminders: [ReminderItem] = []
    @State private var hasLoaded = false
    @State private var openedReminder: ReminderItem?
    @State private var isComposing = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(String(localized: "Inbox.Title", table: "Reminders"))
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ReminderInboxToolbar(isPresented: $isPresented, isComposing: $isComposing)
                }
        }
        .accessibilityIdentifier("ReminderInbox")
        .presentationDetents([.medium, .large])
        .sheet(item: $openedReminder) { reminder in
            ReminderEditorView(reminder: reminder)
        }
        .sheet(isPresented: $isComposing) {
            ReminderEditorView(initialDate: nil)
        }
        .task(id: LoadKey(revision: store.contentRevision, calendar: systemTime.calendar)) {
            reminders = await store.undatedReminders(calendar: systemTime.calendar)
            hasLoaded = true
        }
    }

    @ViewBuilder
    private var content: some View {
        if !store.reminderAuthorization.allowsReading {
            PermissionBlockedView(kind: .reminders, requestable: [])
        } else if hasLoaded && reminders.isEmpty {
            ContentUnavailableView(
                String(localized: "Inbox.Empty.Title", table: "Reminders"),
                systemImage: "tray",
                description: Text(String(localized: "Inbox.Empty.Description", table: "Reminders"))
            )
        } else {
            List(reminders) { reminder in
                AgendaReminderRow(reminder: reminder) { openedReminder = reminder }
            }
        }
    }

    private struct LoadKey: Equatable {
        let revision: Int
        let calendar: Calendar
    }
}
