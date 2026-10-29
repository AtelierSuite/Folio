import Planner
import SwiftUI

struct ReminderSettingsSection: View {
    @Environment(CalendarStore.self) private var store

    private var overduePolicy: Binding<OverdueReminderPolicy> {
        Binding(get: { store.overdueReminderPolicy }, set: { store.setOverdueReminderPolicy($0) })
    }

    var body: some View {
        Section {
            Picker(String(localized: "Settings.Overdue", table: "Reminders"), selection: overduePolicy) {
                ForEach(OverdueReminderPolicy.allCases) { policy in
                    Text(policy.title).tag(policy)
                }
            }
            .accessibilityIdentifier("OverdueReminderPolicyPicker")
        } header: {
            Text(String(localized: "Settings.Header", table: "Reminders"))
        } footer: {
            Text(String(localized: "Settings.Overdue.Footer", table: "Reminders"))
        }
    }
}

extension OverdueReminderPolicy {
    var title: String {
        switch self {
        case .carryForward: String(localized: "Settings.Overdue.CarryForward", table: "Reminders")
        case .keepOnDueDate: String(localized: "Settings.Overdue.KeepOnDueDate", table: "Reminders")
        }
    }
}
