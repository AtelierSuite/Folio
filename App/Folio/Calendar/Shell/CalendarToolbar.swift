import SwiftUI

struct CalendarToolbar: ToolbarContent {
    @Binding var mode: CalendarViewMode
    @Binding var composer: CalendarComposer?
    @Binding var isShowingInbox: Bool
    let navigation: CalendarNavigation
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    #else
    private let isCompact = false
    #endif

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            if !isCompact {
                ReminderInboxButton(isShowingInbox: $isShowingInbox)
            }
            CalendarAddMenu(composer: $composer)
            CalendarViewModeMenu(mode: $mode, isShowingInbox: $isShowingInbox, includesInbox: isCompact)
        }
        InvitationsToolbarItem()
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
