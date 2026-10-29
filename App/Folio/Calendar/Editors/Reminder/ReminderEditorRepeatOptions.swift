import Planner
import SwiftUI

struct ReminderEditorRepeatOptions: View {
    let recurrence: ReminderRecurrence
    let dueDate: Date?
    let onChange: (ReminderRecurrence) -> Void

    private var interval: Binding<Int> {
        Binding(get: { recurrence.interval }, set: { interval in update { $0.interval = interval } })
    }

    private var hasEndDate: Binding<Bool> {
        Binding(
            get: { recurrence.endDate != nil },
            set: { isOn in
                let defaultEnd = Calendar.current.date(byAdding: .month, value: 1, to: dueDate ?? .now)
                update { $0.endDate = isOn ? defaultEnd : nil }
            }
        )
    }

    private var endDate: Binding<Date> {
        Binding(get: { recurrence.endDate ?? dueDate ?? .now }, set: { date in update { $0.endDate = date } })
    }

    var body: some View {
        Stepper(value: interval, in: 1...99) {
            Text(recurrence.frequency.intervalTitle(recurrence.interval))
        }
        Toggle(String(localized: "Repeat.End", table: "ReminderEditor"), isOn: hasEndDate)
        if recurrence.endDate != nil {
            DatePicker(
                String(localized: "Repeat.EndDate", table: "ReminderEditor"),
                selection: endDate,
                in: (dueDate ?? .distantPast)...,
                displayedComponents: .date
            )
        }
    }

    private func update(_ change: (inout ReminderRecurrence) -> Void) {
        var updated = recurrence
        change(&updated)
        onChange(updated)
    }
}
