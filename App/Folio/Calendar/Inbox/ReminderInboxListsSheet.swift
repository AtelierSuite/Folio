import SwiftUI

struct ReminderInboxListsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            AccountsSettingsView()
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(role: .confirm) { dismiss() }
                            .accessibilityLabel(String(localized: "Inbox.Close", table: "Reminders"))
                    }
                }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 480)
        #endif
    }
}
