import Planner
import SwiftUI

struct NotificationSoundsView: View {
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(CalendarStore.self) private var store
    @State private var player = NotificationSoundPreviewPlayer()

    var body: some View {
        Form {
            section(for: .event, calendars: store.eventCalendars, isIncluded: scheduler.includesEvents) {
                Text(String(localized: "Section.Events", table: "NotificationSounds"))
            }
            section(for: .reminder, calendars: store.reminderLists, isIncluded: scheduler.includesReminders) {
                Text(String(localized: "Section.Reminders", table: "NotificationSounds"))
            }
        }
        .settingsCategoryStyle(.notificationSounds)
        .onDisappear {
            player.stop()
        }
    }

    private func section(
        for kind: CalendarItemKind,
        calendars: [PlannerCalendar],
        isIncluded: Bool,
        @ViewBuilder header: () -> some View
    ) -> some View {
        Section {
            NotificationSoundPicker(kind: kind, calendar: nil, player: player)
            ForEach(calendars) { NotificationSoundPicker(kind: kind, calendar: $0, player: player) }
        } header: {
            header()
        } footer: {
            if !calendars.isEmpty {
                Text(String(localized: "Section.Footer", table: "NotificationSounds"))
            }
        }
        .disabled(!scheduler.isEnabled || !isIncluded)
    }
}
