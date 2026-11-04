import Planner
import SwiftUI

/// Holds every calendar toolbar control except Add on narrow screens, so the month title keeps its room.
struct CalendarMoreMenu: View {
    @Binding var mode: CalendarViewMode
    @Binding var isShowingInbox: Bool
    let invitationCounts: InvitationCounts
    @AppStorage("Calendar.MultiDayCount") private var dayCount: MultiDayCount = .three
    @State private var isShowingInvitations = false

    var body: some View {
        Menu(String(localized: "Toolbar.More", table: "Calendar"), systemImage: "ellipsis") {
            CalendarViewModePicker(mode: $mode)
                .pickerStyle(.inline)
            if mode == .multiDay {
                MultiDayCountPicker(dayCount: $dayCount)
                    .pickerStyle(.menu)
            }
            Section {
                ReminderInboxButton(isShowingInbox: $isShowingInbox)
                if invitationCounts.hasPendingInvitations {
                    Button(String(localized: "Toolbar.Invitations", table: "Invitations"), systemImage: "envelope") {
                        isShowingInvitations = true
                    }
                    .badge(invitationCounts.pending)
                    .accessibilityIdentifier("InvitationsButton")
                }
            }
        }
        .badge(invitationCounts.pending)
        .accessibilityIdentifier("CalendarMoreMenu")
        .sheet(isPresented: $isShowingInvitations) {
            InvitationsView()
        }
    }
}
