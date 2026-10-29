import Planner
import SwiftUI

struct ReminderEditorDateSection: View {
    @Binding var draft: ReminderDraft
    let defaultDate: Date

    private var hasDueDate: Binding<Bool> {
        Binding(get: { draft.dueDate != nil }, set: { draft.setHasDueDate($0, defaultDate: defaultDate) })
    }

    private var hasDueTime: Binding<Bool> {
        Binding(get: { draft.hasDueTime }, set: { draft.setHasDueTime($0) })
    }

    private var dueDate: Binding<Date> {
        Binding(get: { draft.dueDate ?? defaultDate }, set: { draft.dueDate = $0 })
    }

    var body: some View {
        Section {
            Toggle(String(localized: "Field.Date", table: "ReminderEditor"), isOn: hasDueDate)
            if draft.dueDate != nil {
                DatePicker(
                    String(localized: "Field.Date", table: "ReminderEditor"),
                    selection: dueDate,
                    displayedComponents: .date
                )
                Toggle(String(localized: "Field.Time", table: "ReminderEditor"), isOn: hasDueTime)
                if draft.hasDueTime {
                    DatePicker(
                        String(localized: "Field.Time", table: "ReminderEditor"),
                        selection: dueDate,
                        displayedComponents: .hourAndMinute
                    )
                }
            }
        }
    }
}
