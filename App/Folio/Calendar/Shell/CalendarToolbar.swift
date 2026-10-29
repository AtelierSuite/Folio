import SwiftUI

struct CalendarToolbar: ToolbarContent {
    @Binding var mode: CalendarViewMode
    @Binding var composer: CalendarComposer?
    @Binding var isShowingInbox: Bool
    let navigation: CalendarNavigation

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            ReminderInboxButton(isShowingInbox: $isShowingInbox)
            CalendarAddMenu(composer: $composer)
            Picker(String(localized: "Toolbar.ViewMode", table: "Calendar"), selection: $mode) {
                ForEach(CalendarViewMode.allCases) { mode in
                    Label(mode.title, systemImage: mode.systemImage)
                        .tag(mode)
                }
            }
            .pickerStyle(.menu)
        }
        ToolbarItemGroup(placement: .navigation) {
            Button(String(localized: "Toolbar.Previous", table: "Calendar"), systemImage: "chevron.left") {
                navigation.page(mode, forward: false)
            }
            Button(String(localized: "Toolbar.Today", table: "Calendar")) {
                navigation.goToToday()
            }
            .disabled(navigation.isShowingToday)
            Button(String(localized: "Toolbar.Next", table: "Calendar"), systemImage: "chevron.right") {
                navigation.page(mode, forward: true)
            }
        }
    }
}
