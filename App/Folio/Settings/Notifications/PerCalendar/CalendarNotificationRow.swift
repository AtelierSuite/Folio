import Planner
import SwiftUI

struct CalendarNotificationRow: View {
    @Environment(NotificationScheduler.self) private var scheduler
    let calendar: PlannerCalendar
    let player: NotificationSoundPreviewPlayer
    @State private var style = NotificationStyleSettings.initialStyle
    @State private var isPresented = false

    var body: some View {
        link
            .accessibilityIdentifier("CalendarNotificationRow.\(calendar.title)")
            .onAppear {
                style = scheduler.defaultStyle(forCalendar: calendar.id)
            }
    }

    @ViewBuilder
    private var link: some View {
        #if os(macOS)
        Button {
            isPresented = true
        } label: {
            label
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isPresented) {
            SettingsSheet(title: calendar.title) {
                detail
            }
        }
        #else
        NavigationLink {
            detail
                .navigationTitle(calendar.title)
                .toolbarTitleDisplayMode(.inline)
        } label: {
            label
        }
        #endif
    }

    private var detail: some View {
        CalendarNotificationDetailView(calendar: calendar, player: player, style: $style)
    }

    private var label: some View {
        HStack {
            CalendarKindLabel(calendar: calendar)
            Spacer()
            Text(style.title)
                .foregroundStyle(.secondary)
            #if os(macOS)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
            #endif
        }
    }
}
