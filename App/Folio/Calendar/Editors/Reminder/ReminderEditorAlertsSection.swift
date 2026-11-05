import Planner
import SwiftUI

struct ReminderEditorAlertsSection: View {
    @Binding var draft: ReminderDraft
    @Binding var earlyAlerts: [ReminderEarlyAlert]

    var body: some View {
        Section {
            ForEach(draft.alarms.indices, id: \.self) { index in
                ReminderEditorAlertRow(alarm: $draft.alarms[index]) {
                    draft.alarms.remove(at: index)
                }
            }
            if draft.dueDate != nil {
                ForEach(earlyAlerts.indices, id: \.self) { index in
                    ReminderEditorEarlyAlertRow(alert: $earlyAlerts[index]) {
                        earlyAlerts.remove(at: index)
                    }
                }
            }
            ReminderEditorAddAlertMenu(draft: $draft, earlyAlerts: $earlyAlerts)
        } header: {
            Text(String(localized: "Alerts.Header", table: "ReminderEditor"))
        } footer: {
            VStack(alignment: .leading) {
                if !draft.canUseRelativeAlarms {
                    Text(String(localized: "Alerts.NeedsDueTime", table: "ReminderEditor"))
                }
                if draft.dueDate != nil && !earlyAlerts.isEmpty {
                    Text(String(localized: "Alerts.EarlyNote", table: "ReminderEditor"))
                }
            }
        }
    }
}
