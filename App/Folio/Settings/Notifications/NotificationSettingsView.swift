import Planner
import SwiftUI

struct NotificationSettingsView: View {
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        Form {
            Section {
                Toggle(String(localized: "Enabled", table: "Notifications"), isOn: binding(
                    get: { scheduler.isEnabled },
                    set: {
                        await scheduler.setEnabled($0)
                        await permissionCenter.refresh(.notifications)
                    }
                ))
                .accessibilityIdentifier("NotificationsEnabledToggle")
            } footer: {
                Text(String(localized: "Enabled.Footer", table: "Notifications"))
            }
            if scheduler.authorization == .denied {
                NotificationDeniedSection()
            }
            Section(String(localized: "Items.Section", table: "Notifications")) {
                Toggle(String(localized: "Items.Events", table: "Notifications"), isOn: binding(
                    get: { scheduler.includesEvents },
                    set: { await scheduler.setIncludesEvents($0) }
                ))
                Toggle(String(localized: "Items.Reminders", table: "Notifications"), isOn: binding(
                    get: { scheduler.includesReminders },
                    set: { await scheduler.setIncludesReminders($0) }
                ))
                NavigationLink(String(localized: "Defaults.Title", table: "NotificationStyles")) {
                    NotificationStyleDefaultsView()
                }
                .accessibilityIdentifier("NotificationStylesLink")
            }
            .disabled(!scheduler.isEnabled)
            LeaveAlertsSection()
            ArrivalAlertsSection()
            if scheduler.isEnabled {
                NotificationStatusSection()
            }
        }
        .formStyle(.grouped)
        .navigationTitle(String(localized: "Title", table: "Notifications"))
        .toolbarTitleDisplayMode(.inline)
        .task {
            await scheduler.replan()
        }
    }

    private func binding(get: @escaping () -> Bool, set: @escaping (Bool) async -> Void) -> Binding<Bool> {
        Binding(get: get, set: { newValue in Task { await set(newValue) } })
    }
}
