import SwiftUI

struct ReminderInboxToolbar: ToolbarContent {
    @Binding var isPresented: Bool
    @Binding var isComposing: Bool
    @Binding var isShowingLists: Bool

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(String(localized: "Inbox.Close", table: "Reminders"), systemImage: "xmark", role: .close) {
                isPresented = false
            }
        }
        ToolbarItemGroup(placement: .primaryAction) {
            Button(String(localized: "Inbox.Lists", table: "Reminders"), systemImage: "line.3.horizontal.decrease") {
                isShowingLists = true
            }
            .accessibilityIdentifier("ReminderInboxListsLink")
            Button(String(localized: "Inbox.New", table: "Reminders"), systemImage: "plus") {
                isComposing = true
            }
        }
    }
}
