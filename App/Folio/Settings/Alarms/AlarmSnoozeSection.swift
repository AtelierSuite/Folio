import Planner
import SwiftUI

struct AlarmSnoozeSection: View {
    @Environment(NotificationScheduler.self) private var notificationScheduler
    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms
    @Environment(StandaloneAlarmCenter.self) private var standaloneAlarms
    @State private var minutes = AlarmSnoozeSettings().minutes

    var body: some View {
        Section {
            Picker(String(localized: "Snooze.Time", table: "Alarms"), selection: $minutes) {
                ForEach(AlarmSnoozeSettings.choices, id: \.self) { choice in
                    Text(NotificationSnoozeDurations.title(forMinutes: choice)).tag(choice)
                }
            }
            .accessibilityIdentifier("AlarmSnoozeTimePicker")
        } footer: {
            Text(String(localized: "Snooze.Footer", table: "Alarms"))
        }
        .onChange(of: minutes) { _, newValue in
            AlarmSnoozeSettings().minutes = newValue
            Task {
                await notificationScheduler.replan()
                await wakeUpAlarms.replan()
                await standaloneAlarms.replan()
            }
        }
    }
}
