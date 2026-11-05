import Planner
import SwiftUI

struct ReminderEditorEarlyAlertRow: View {
    @Binding var alert: ReminderEarlyAlert
    let onRemove: () -> Void

    var body: some View {
        HStack {
            Button(
                String(localized: "Alert.Remove", table: "ReminderEditor"),
                systemImage: "minus.circle.fill",
                action: onRemove
            )
                .labelStyle(.iconOnly)
                .foregroundStyle(.red)
                .buttonStyle(.plain)
            Picker(String(localized: "Alert.EarlyUnit", table: "ReminderEditor"), selection: $alert.unit) {
                ForEach(ReminderEarlyAlert.Unit.allCases, id: \.self) { unit in
                    Text(ReminderEarlyAlert(count: alert.count, unit: unit).title).tag(unit)
                }
            }
            .labelsHidden()
            .accessibilityIdentifier("ReminderEditor.EarlyAlertUnit")
            Spacer()
            Stepper(
                String(localized: "Alert.EarlyAmount", table: "ReminderEditor"),
                value: $alert.count,
                in: ReminderEarlyAlert.countRange
            )
            .labelsHidden()
            .accessibilityValue(alert.title)
            .accessibilityIdentifier("ReminderEditor.EarlyAlertAmount")
        }
    }
}
