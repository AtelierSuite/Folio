import Planner
import SwiftUI

struct EventEditorForm: View {
    @Binding var draft: EventDraft
    @Binding var urlText: String
    @Binding var alertStyle: NotificationAlertStyle?
    let calendars: [PlannerCalendar]

    var body: some View {
        Form {
            Section {
                TextField(String(localized: "Field.Title", table: "EventEditor"), text: $draft.title)
                EventLocationRow(location: $draft.location)
            }
            EventDateSection(draft: $draft)
            EventRecurrenceSection(recurrence: $draft.recurrence, startDate: draft.startDate)
            Section {
                EventCalendarPicker(selection: $draft.calendarIdentifier, calendars: calendars)
            }
            EventAlertsSection(alerts: $draft.alerts, isAllDay: draft.isAllDay)
            NotificationStyleSection(style: $alertStyle, calendarIdentifier: draft.calendarIdentifier)
            EventDetailsSection(urlText: $urlText, notes: $draft.notes)
        }
        .formStyle(.grouped)
        .scrollDismissesKeyboard(.interactively)
    }
}
