import Planner
import SwiftUI

struct NotificationSettingsView: View {
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(PermissionCenter.self) private var permissionCenter

    var body: some View {
        Form {
            NotificationPermissionPromptSection()
            Section {
                Toggle(String(localized: "Enabled", table: "Notifications"), isOn: binding(
                    get: { scheduler.isEnabled },
                    set: {
                        await scheduler.setEnabled($0)
                        await permissionCenter.refresh(.notifications)
                    }
                ))
                .disabled(permissionCenter.isBlocked(.notifications))
                .accessibilityIdentifier("NotificationsEnabledToggle")
            }
            SnoozeDurationsSection()
        }
        .settingsCategoryStyle(.notifications)
        .task(id: permissionCenter.status(of: .notifications)) {
            await scheduler.replan()
        }
    }

    private func binding(get: @escaping () -> Bool, set: @escaping (Bool) async -> Void) -> Binding<Bool> {
        Binding(get: get, set: { newValue in Task { await set(newValue) } })
    }
}
