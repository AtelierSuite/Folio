import Planner
import SwiftUI

struct MedicationSettingsSection: View {
    @Environment(MedicationStore.self) private var store
    @Environment(NotificationScheduler.self) private var scheduler

    var body: some View {
        Section {
            Toggle(String(localized: "Settings.ShowOnTimeline", table: "Medications"), isOn: Binding(
                get: { store.isShownOnTimeline },
                set: { isShown in
                    Task { await setShown(isShown) }
                }
            ))
            .accessibilityIdentifier("MedicationTimelineToggle")
            Toggle(String(localized: "Settings.SendReminders", table: "Medications"), isOn: Binding(
                get: { store.sendsReminders && scheduler.isEnabled },
                set: { sends in
                    Task { await setSends(sends) }
                }
            ))
            .disabled(!scheduler.isEnabled)
            .accessibilityIdentifier("MedicationReminderToggle")
        } footer: {
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: "Settings.Footer", table: "Medications"))
                if !scheduler.isEnabled {
                    Text(String(localized: "Settings.NotificationsOff", table: "Medications"))
                }
            }
        }
    }

    private func setShown(_ isShown: Bool) async {
        await store.setShownOnTimeline(isShown)
        if isShown {
            await requestAccessIfNothingIsShared()
        }
    }

    private func setSends(_ sends: Bool) async {
        await store.setSendsReminders(sends)
        if sends {
            await requestAccessIfNothingIsShared()
        }
    }

    /// Health only reveals what's shared by returning it, and its sheet appears on every request.
    private func requestAccessIfNothingIsShared() async {
        if await store.scheduledMedications().isEmpty {
            await store.requestAccess()
        }
    }
}
