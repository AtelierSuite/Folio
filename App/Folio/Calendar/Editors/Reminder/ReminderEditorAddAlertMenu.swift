import Planner
import SwiftUI

struct ReminderEditorAddAlertMenu: View {
    @Binding var draft: ReminderDraft

    var body: some View {
        Menu(String(localized: "Alerts.Add", table: "ReminderEditor"), systemImage: "plus.circle.fill") {
            ForEach(ReminderAlarm.presetOffsets, id: \.self) { offset in
                let alarm = ReminderAlarm.relative(offset)
                Button(alarm.title) { draft.alarms.append(alarm) }
                    .disabled(!draft.canUseRelativeAlarms || draft.alarms.contains(alarm))
            }
            Divider()
            Button(String(localized: "Alert.Custom", table: "ReminderEditor")) {
                draft.alarms.append(.absolute(defaultAbsoluteDate))
            }
        }
    }

    private var defaultAbsoluteDate: Date {
        if let dueDate = draft.dueDate, draft.hasDueTime, dueDate > .now {
            return dueDate
        }
        let calendar = Calendar.current
        let nextHour = calendar.nextDate(after: .now, matching: DateComponents(minute: 0), matchingPolicy: .nextTime)
        return nextHour ?? .now
    }
}
