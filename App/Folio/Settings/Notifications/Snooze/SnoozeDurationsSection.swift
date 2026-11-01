import Planner
import SwiftUI

struct SnoozeDurationsSection: View {
    @Environment(NotificationScheduler.self) private var scheduler
    @State private var durations = NotificationSnoozeSettings().durations

    var body: some View {
        Section {
            SnoozeDurationPicker(
                title: String(localized: "Snooze.First", table: "Notifications"),
                minutes: binding(\.shortMinutes)
            )
            .accessibilityIdentifier("SnoozeFirstPicker")
            SnoozeDurationPicker(
                title: String(localized: "Snooze.Second", table: "Notifications"),
                minutes: binding(\.longMinutes)
            )
            .accessibilityIdentifier("SnoozeSecondPicker")
        } header: {
            Text(String(localized: "Snooze.Section", table: "Notifications"))
        } footer: {
            Text(String(localized: "Snooze.Footer", table: "Notifications"))
        }
        .disabled(!scheduler.isEnabled)
    }

    private func binding(_ keyPath: WritableKeyPath<NotificationSnoozeDurations, Int>) -> Binding<Int> {
        Binding(
            get: { durations[keyPath: keyPath] },
            set: { newValue in
                durations[keyPath: keyPath] = newValue
                NotificationSnoozeSettings().durations = durations
                NotificationCategoryRegistry.register(snoozing: durations)
            }
        )
    }
}
