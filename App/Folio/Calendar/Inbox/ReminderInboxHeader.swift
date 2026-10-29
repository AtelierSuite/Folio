import SwiftUI

/// Kept in the view rather than the toolbar: on macOS an inspector's toolbar items join the window toolbar.
struct ReminderInboxHeader: View {
    @Binding var isPresented: Bool
    @Binding var isComposing: Bool
    @Binding var isShowingLists: Bool

    var body: some View {
        HStack(spacing: 12) {
            Button(String(localized: "Inbox.Close", table: "Reminders"), systemImage: "xmark") {
                isPresented = false
            }
            Text(String(localized: "Inbox.Title", table: "Reminders"))
                .font(.headline)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(String(localized: "Inbox.Lists", table: "Reminders"), systemImage: "line.3.horizontal.decrease") {
                isShowingLists = true
            }
            .accessibilityIdentifier("ReminderInboxListsLink")
            Button(String(localized: "Inbox.New", table: "Reminders"), systemImage: "plus") {
                isComposing = true
            }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}
