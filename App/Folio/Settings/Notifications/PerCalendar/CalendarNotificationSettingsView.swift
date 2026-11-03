import Planner
import SwiftUI

struct CalendarNotificationSettingsView: View {
    @Environment(CalendarStore.self) private var store
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(PermissionCenter.self) private var permissionCenter
    @Environment(\.platformCapabilities) private var capabilities
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
            let groups = CalendarAccountGroup.groups(calendars: calendars, lists: [])
            ForEach(groups) { group in
                ForEach(group.calendars) { calendar in
                    CalendarNotificationSection(
                        calendar: calendar,
                        accountTitle: group.title,
                        player: player,
                        footer: calendar.id == groups.last?.calendars.last?.id ? footer : nil
                    )
                    .disabled(!isIncluded)
                }
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

    private var footer: String {
        let styleFooter = capabilities.supports(.alarms)
            ? String(localized: "Defaults.Footer.Alarms", table: "NotificationStyles")
            : String(localized: "Defaults.Footer", table: "NotificationStyles")
        guard kind == .event else { return styleFooter }
        return styleFooter + " " + String(localized: "AllDay.Footer", table: "Notifications")
    }
}
