import Planner
import SwiftUI

struct ReminderEditorListSection: View {
    @Environment(CalendarStore.self) private var store
    @Binding var draft: ReminderDraft

    private var lists: [PlannerCalendar] {
        store.reminderLists.filter { !$0.isReadOnly || $0.id == draft.listIdentifier }
    }

    var body: some View {
        Section {
            Picker(String(localized: "Field.List", table: "ReminderEditor"), selection: $draft.listIdentifier) {
                if draft.listIdentifier.isEmpty {
                    Text(String(localized: "List.None", table: "ReminderEditor")).tag("")
                }
                ForEach(CalendarAccountGroup.groups(from: lists)) { group in
                    Section(group.title) {
                        ForEach(group.calendars) { list in
                            Label {
                                Text(list.title)
                            } icon: {
                                Image(coloredSymbol: "circle.fill", color: list.color)
                            }
                            .tag(list.id)
                        }
                    }
                }
            }
            Picker(String(localized: "Field.Priority", table: "ReminderEditor"), selection: $draft.priority) {
                ForEach([ReminderPriority.none, .low, .medium, .high]) { priority in
                    Text(priority.title).tag(priority)
                }
            }
        } footer: {
            if lists.isEmpty {
                Text(String(localized: "List.Empty", table: "ReminderEditor"))
            }
        }
    }
}
