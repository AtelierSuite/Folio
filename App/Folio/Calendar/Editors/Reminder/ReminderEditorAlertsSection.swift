import Planner
import SwiftUI

struct ReminderEditorAlertsSection: View {
    @Binding var draft: ReminderDraft

    var body: some View {
        Section {
            ForEach(draft.alarms.indices, id: \.self) { index in
                ReminderEditorAlertRow(alarm: $draft.alarms[index]) {
                    draft.alarms.remove(at: index)
                }
            }
            ReminderEditorAddAlertMenu(draft: $draft)
        } header: {
            Text(String(localized: "Alerts.Header", table: "ReminderEditor"))
        } footer: {
            if !draft.canUseRelativeAlarms {
                Text(String(localized: "Alerts.NeedsDueTime", table: "ReminderEditor"))
            }
        }
    }
}
