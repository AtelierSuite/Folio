import Planner
import SwiftUI

struct CalendarNotificationSettingsView: View {
    @Environment(CalendarStore.self) private var store
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(PermissionCenter.self) private var permissionCenter
    @State private var player = NotificationSoundPreviewPlayer()
    let kind: CalendarItemKind

    var body: some View {
        Form {
            if permissionCenter.status(of: .alarms) == .denied {
                NotificationAlarmDeniedSection()
            }
            Section {
                NotificationSoundPicker(kind: kind, calendar: nil, player: player)
            } footer: {
                Text(String(localized: "Section.Footer", table: "NotificationSounds"))
            }
            .disabled(!isIncluded)
            if calendars.isEmpty {
                Text(emptyText)
                    .foregroundStyle(.secondary)
            }
            ForEach(CalendarAccountGroup.groups(from: calendars)) { group in
                Section(group.title) {
                    ForEach(group.calendars) { calendar in
                        CalendarNotificationRow(calendar: calendar, player: player)
                    }
                }
                .disabled(!isIncluded)
            }
        }
        .accessibilityIdentifier("CalendarNotificationSettings.\(kind == .event ? "Events" : "Reminders")")
        .settingsCategoryStyle(kind == .event ? .eventNotifications : .reminderNotifications)
        .task {
            await permissionCenter.refresh(.alarms)
        }
        .onDisappear {
            player.stop()
        }
    }

    private var calendars: [PlannerCalendar] {
        kind == .event ? store.eventCalendars : store.reminderLists
    }

    private var isIncluded: Bool {
        scheduler.isEnabled && (kind == .event ? scheduler.includesEvents : scheduler.includesReminders)
    }

    private var emptyText: String {
        kind == .event
            ? String(localized: "AllDay.Empty", table: "Notifications")
            : String(localized: "Empty.Lists", table: "Notifications")
    }
}
