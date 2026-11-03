import SwiftUI

struct StandaloneAlarmComposerForm: View {
    @Binding var fireDate: Date
    @Binding var label: String

    var body: some View {
        Form {
            Section {
                DatePicker(
                    String(localized: "Composer.Time", table: "StandaloneAlarms"),
                    selection: $fireDate,
                    in: Date.now...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .accessibilityIdentifier("StandaloneAlarmComposer.Time")
                TextField(
                    String(localized: "Composer.Label", table: "StandaloneAlarms"),
                    text: $label,
                    prompt: Text(String(localized: "Composer.LabelPlaceholder", table: "StandaloneAlarms"))
                )
                .accessibilityIdentifier("StandaloneAlarmComposer.Label")
            } footer: {
                Text(String(localized: "Composer.Footer", table: "StandaloneAlarms"))
            }
        }
        .formStyle(.grouped)
    }
}
