import SwiftUI

/// Holds every calendar toolbar control except Add on narrow screens, so the month title keeps its room.
struct CalendarMoreMenu: View {
    @Binding var mode: CalendarViewMode
    @Binding var isShowingInbox: Bool
    let pendingInvitationCount: Int
    @AppStorage("Calendar.MultiDayCount") private var dayCount: MultiDayCount = .three
    @AppStorage(CalendarWeekLayout.storageKey) private var weekLayout: CalendarWeekLayout = .allDays
    @State private var isShowingInvitations = false

    var body: some View {
        Menu(String(localized: "Toolbar.More", table: "Calendar"), systemImage: "ellipsis") {
            Section {
                MenuChoiceToggles(
                    choices: CalendarViewMode.allCases, selection: $mode, title: \.title, systemImage: \.systemImage
                )
            }
            if mode == .multiDay {
                Menu {
                    MenuChoiceToggles(
                        choices: MultiDayCount.allCases, selection: $dayCount,
                        title: \.title, systemImage: \.systemImage
                    )
                } label: {
                    Label(String(localized: "DayCount.Picker", table: "Day"), systemImage: dayCount.systemImage)
                    Text(dayCount.title)
                }
            }
            if mode.hasWeekLayouts {
                Menu {
                    MenuChoiceToggles(
                        choices: CalendarWeekLayout.allCases, selection: $weekLayout,
                        title: \.title, systemImage: \.systemImage
                    )
                } label: {
                    Label(
                        String(localized: "WeekLayout.Picker", table: "Calendar"), systemImage: weekLayout.systemImage
                    )
                    Text(weekLayout.title)
                }
            }
            Section {
                ReminderInboxButton(isShowingInbox: $isShowingInbox)
                Button(String(localized: "Toolbar.Invitations", table: "Invitations"), systemImage: "envelope") {
                    isShowingInvitations = true
                }
                .badge(pendingInvitationCount)
                .accessibilityIdentifier("InvitationsButton")
                FlexTimeButton()
            }
        }
        .badge(pendingInvitationCount)
        .accessibilityIdentifier("CalendarMoreMenu")
        .sheet(isPresented: $isShowingInvitations) {
            InvitationsView()
        }
    }
}
