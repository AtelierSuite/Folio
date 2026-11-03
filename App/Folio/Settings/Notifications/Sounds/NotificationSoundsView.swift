import Planner
import SwiftUI

struct NotificationSoundsView: View {
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(CalendarStore.self) private var store

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
    }

    private func section(
        for kind: CalendarItemKind,
        calendars: [PlannerCalendar],
        isIncluded: Bool,
        @ViewBuilder header: () -> some View
    ) -> some View {
        Section {
            NavigationLink {
                NotificationSoundPickerView(kind: kind, calendar: nil)
            } label: {
                LabeledContent(
                    String(localized: "Row.Default", table: "NotificationSounds"),
                    value: scheduler.sound(for: kind).title
                )
            }
            .accessibilityIdentifier("NotificationSoundDefault.\(kind == .event ? "Events" : "Reminders")")
            ForEach(calendars) { NotificationSoundCalendarLink(kind: kind, calendar: $0) }
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
