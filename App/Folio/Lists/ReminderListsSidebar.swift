import Planner
import SwiftUI

struct ReminderListsSidebar: View {
    @Environment(CalendarStore.self) private var store
    @Environment(SystemTimeObserver.self) private var systemTime
    @Binding var selection: String?
    @State private var openCounts: [String: Int] = [:]

    var body: some View {
        content
            .navigationTitle(String(localized: "Title", table: "Lists"))
            .task(id: LoadKey(revision: store.contentRevision, calendar: systemTime.calendar)) {
                openCounts = await store.openReminderCounts(calendar: systemTime.calendar)
            }
    }

    @ViewBuilder
    private var content: some View {
        if !store.reminderAuthorization.allowsReading {
            PermissionBlockedView(kind: .reminders, requestable: [])
        } else if store.reminderLists.isEmpty {
            ContentUnavailableView(
                String(localized: "Empty.Title", table: "Lists"),
                systemImage: "checklist",
                description: Text(String(localized: "Empty.Description", table: "Lists"))
            )
        } else {
            List(selection: $selection) {
                ForEach(ReminderListGroup.groups(from: store.reminderLists)) { group in
                    Section(group.title) {
                        ForEach(group.lists) { list in
                            ReminderListRow(list: list, openCount: openCounts[list.id] ?? 0)
                                .tag(list.id)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .accessibilityIdentifier("ReminderListsSidebar")
        }
    }

    private struct LoadKey: Equatable {
        let revision: Int
        let calendar: Calendar
    }
}
