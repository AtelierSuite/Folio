import Planner
import SwiftUI

struct ReminderEditorRepeatSection: View {
    @Binding var recurrence: ReminderRecurrence?
    let dueDate: Date?

    private var frequency: Binding<ReminderRecurrence.Frequency?> {
        Binding(
            get: { recurrence?.frequency },
            set: { frequency in
                if let frequency {
                    recurrence = ReminderRecurrence(
                        frequency: frequency,
                        interval: recurrence?.interval ?? 1,
                        endDate: recurrence?.endDate
                    )
                } else {
                    recurrence = nil
                }
            }
        )
    }

    var body: some View {
        Section {
            Picker(String(localized: "Field.Repeat", table: "ReminderEditor"), selection: frequency) {
                Text(String(localized: "Repeat.Never", table: "ReminderEditor"))
                    .tag(ReminderRecurrence.Frequency?.none)
                ForEach(ReminderRecurrence.Frequency.allCases) { frequency in
                    Text(frequency.title).tag(Optional(frequency))
                }
            }
            if let current = recurrence {
                ReminderEditorRepeatOptions(recurrence: current, dueDate: dueDate) { recurrence = $0 }
            }
        }
    }
}
