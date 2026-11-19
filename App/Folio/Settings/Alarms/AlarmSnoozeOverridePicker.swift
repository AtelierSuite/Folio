import Planner
import SwiftUI

/// Picks an alarm's own snooze time, where `nil` follows the Snooze Time setting.
struct AlarmSnoozeOverridePicker: View {
    @Binding var minutes: Int?

    var body: some View {
        Picker(String(localized: "Snooze.Time", table: "Alarms"), selection: $minutes) {
            Text(defaultTitle).tag(Int?.none)
            ForEach(AlarmSnoozeSettings.choices, id: \.self) { choice in
                Text(NotificationSnoozeDurations.title(forMinutes: choice)).tag(Int?.some(choice))
            }
        }
    }

    private var defaultTitle: String {
        String(
            format: String(localized: "Snooze.Default", table: "Alarms"),
            NotificationSnoozeDurations.title(forMinutes: AlarmSnoozeSettings().minutes)
        )
    }
}
