import SwiftUI

struct ReminderInboxToolbar: ToolbarContent {
    @Binding var isPresented: Bool
    @Binding var isComposing: Bool

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(String(localized: "Inbox.Close", table: "Reminders"), systemImage: "xmark") {
                isPresented = false
            }
        }
        ToolbarItemGroup(placement: .primaryAction) {
            NavigationLink {
                CalendarVisibilityView()
            } label: {
                Label(String(localized: "Inbox.Lists", table: "Reminders"), systemImage: "line.3.horizontal.decrease")
            }
            .accessibilityIdentifier("ReminderInboxListsLink")
            Button(String(localized: "Inbox.New", table: "Reminders"), systemImage: "plus") {
                isComposing = true
            }
        }
    }
}
