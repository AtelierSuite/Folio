import Planner
import SwiftUI

struct StandaloneAlarmComposerForm: View {
    @Binding var fireDate: Date
    @Binding var label: String
    @Binding var snoozeMinutes: Int?
    @Binding var sound: AlarmSound
    /// Shown only when editing an alarm that's already set.
    let delete: (() -> Void)?

    var body: some View {
        Form {
            Section {
                TextField(
                    String(localized: "Composer.Label", table: "StandaloneAlarms"),
                    text: $label,
                    prompt: Text(String(localized: "Composer.LabelPlaceholder", table: "StandaloneAlarms"))
                )
                .accessibilityIdentifier("StandaloneAlarmComposer.Label")
            }
            Section {
                DatePicker(
                    String(localized: "Composer.Time", table: "StandaloneAlarms"),
                    selection: $fireDate,
                    in: Date.now...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .accessibilityIdentifier("StandaloneAlarmComposer.Time")
                AlarmSnoozeOverridePicker(minutes: $snoozeMinutes)
                    .accessibilityIdentifier("StandaloneAlarmComposer.Snooze")
                AlarmSoundPicker(
                    selection: sound,
                    select: { sound = $0 },
                    accessibilityIdentifier: "StandaloneAlarmComposer.Sound"
                )
            } footer: {
                Text(String(localized: "Composer.Footer", table: "StandaloneAlarms"))
            }
            if let delete {
                Section {
                    Button(
                        String(localized: "Marker.Delete", table: "StandaloneAlarms"),
                        role: .destructive,
                        action: delete
                    )
                    .frame(maxWidth: .infinity)
                    .accessibilityIdentifier("StandaloneAlarmEditor.Delete")
                }
            }
        }
        .formStyle(.grouped)
    }
}
