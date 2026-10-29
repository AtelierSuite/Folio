import SwiftUI

struct ReminderInboxButton: View {
    @Binding var isShowingInbox: Bool

    var body: some View {
        Button(String(localized: "Inbox.Toggle", table: "Reminders"), systemImage: "tray") {
            isShowingInbox.toggle()
        }
        .accessibilityIdentifier("ReminderInboxButton")
    }
}
