import SwiftUI
import Planner

struct CalendarToolbar: ToolbarContent {
    @Binding var mode: CalendarViewMode
    @Binding var composer: CalendarComposer?
    @Binding var isShowingInbox: Bool
    let navigation: CalendarNavigation
    var pendingInvitationCount = 0
    @Environment(\.platformCapabilities) private var capabilities
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
        if pendingInvitationCount > 0 {
            InvitationsToolbarItem(pendingCount: pendingInvitationCount)
        }
        ToolbarItemGroup(placement: .navigation) {
            if capabilities.supports(.calendarPagingButtons) {
                Button(String(localized: "Toolbar.Previous", table: "Calendar"), systemImage: "chevron.left") {
                    navigation.page(mode, forward: false)
                }
            }
            Button(String(localized: "Toolbar.Today", table: "Calendar")) {
                navigation.goToToday()
            }
            .disabled(navigation.isShowingToday)
            if capabilities.supports(.calendarPagingButtons) {
                Button(String(localized: "Toolbar.Next", table: "Calendar"), systemImage: "chevron.right") {
                    navigation.page(mode, forward: true)
                }
            }
        }
    }
}
