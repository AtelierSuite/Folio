import Planner
import SwiftUI

struct ReminderEditorAlertRow: View {
    @Binding var alarm: ReminderAlarm
    let onRemove: () -> Void

    private var absoluteDate: Binding<Date> {
        Binding(get: { alarm.fireDate(dueDate: nil) ?? .now }, set: { alarm = .absolute($0) })
    }

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
            if alarm.isRelative {
                Text(alarm.title)
            } else {
                DatePicker(String(localized: "Alert.OnDate", table: "ReminderEditor"), selection: absoluteDate)
            }
        }
    }
}
