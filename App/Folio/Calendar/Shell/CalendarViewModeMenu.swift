import SwiftUI

/// The view mode picker. On narrow screens it also holds the undated reminders inbox, since one more
/// toolbar button would push the month title out of the navigation bar.
struct CalendarViewModeMenu: View {
    @Binding var mode: CalendarViewMode
    @Binding var isShowingInbox: Bool
    let includesInbox: Bool

    var body: some View {
        if includesInbox {
            Menu {
                picker
                    .pickerStyle(.inline)
                Section {
                    ReminderInboxButton(isShowingInbox: $isShowingInbox)
                }
            } label: {
                Label(String(localized: "Toolbar.ViewMode", table: "Calendar"), systemImage: mode.systemImage)
            }
            .accessibilityIdentifier("CalendarViewModeMenu")
        } else {
            picker
                .pickerStyle(.menu)
        }
    }

    private var picker: some View {
        Picker(String(localized: "Toolbar.ViewMode", table: "Calendar"), selection: $mode) {
            ForEach(CalendarViewMode.allCases) { mode in
                Label(mode.title, systemImage: mode.systemImage)
                    .tag(mode)
            }
        }
    }
}
