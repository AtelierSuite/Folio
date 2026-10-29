import SwiftUI

struct ReminderInboxListsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            CalendarVisibilityView()
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(String(localized: "Inbox.Close", table: "Reminders")) { dismiss() }
                    }
                }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 480)
        #endif
    }
}
