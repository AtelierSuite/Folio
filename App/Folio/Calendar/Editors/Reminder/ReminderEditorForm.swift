import Planner
import SwiftUI

struct ReminderEditorForm: View {
    @Binding var draft: ReminderDraft
    @Binding var urlText: String
    @Binding var alertStyle: NotificationAlertStyle?
    let isReadOnly: Bool
    let canDelete: Bool
    let canConvert: Bool
    let isNew: Bool
    let defaultDate: Date
    let onConvert: () -> Void
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
                ReminderEditorDetailsSection(draft: $draft, urlText: $urlText, focusesTitle: isNew)
                ReminderEditorListSection(draft: $draft)
                ReminderEditorDateSection(draft: $draft, defaultDate: defaultDate)
                if draft.canRepeat {
                    ReminderEditorRepeatSection(recurrence: $draft.recurrence, dueDate: draft.dueDate)
                }
                ReminderEditorAlertsSection(draft: $draft)
                NotificationStyleSection(style: $alertStyle, calendarIdentifier: draft.listIdentifier)
            }
            .disabled(isReadOnly)
            Section {
                if canConvert {
                    Button(String(localized: "Action.ConvertToEvent", table: "ReminderEditor"), action: onConvert)
                        .accessibilityIdentifier("ReminderEditor.ConvertToEvent")
                }
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
