import Planner
import SwiftUI

struct ReminderEditorForm: View {
    @Binding var draft: ReminderDraft
    @Binding var urlText: String
    let isReadOnly: Bool
    let canDelete: Bool
    let defaultDate: Date
    let onDelete: () -> Void

    var body: some View {
        Form {
            if isReadOnly {
                Section {
                    Label(String(localized: "ReadOnly.Notice", table: "ReminderEditor"), systemImage: "lock.fill")
                        .foregroundStyle(.secondary)
                }
            }
            Group {
                ReminderEditorDetailsSection(draft: $draft, urlText: $urlText)
                ReminderEditorListSection(draft: $draft)
                ReminderEditorDateSection(draft: $draft, defaultDate: defaultDate)
                if draft.canRepeat {
                    ReminderEditorRepeatSection(recurrence: $draft.recurrence, dueDate: draft.dueDate)
                }
                ReminderEditorAlertsSection(draft: $draft)
            }
            .disabled(isReadOnly)
            Section {
                if canDelete {
                    Button(
                        String(localized: "Action.Delete", table: "ReminderEditor"),
                        role: .destructive,
                        action: onDelete
                    )
                }
            } footer: {
                Text(String(localized: "Note.Unavailable", table: "ReminderEditor"))
            }
        }
        .formStyle(.grouped)
    }
}
