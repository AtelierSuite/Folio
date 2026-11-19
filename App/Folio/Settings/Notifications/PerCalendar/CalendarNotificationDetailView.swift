import Planner
import SwiftUI

struct CalendarNotificationDetailView: View {
    let calendar: PlannerCalendar
    let player: NotificationSoundPreviewPlayer
    @Binding var style: NotificationAlertStyle

    var body: some View {
        Form {
            Section {
                NotificationStyleCalendarRow(calendar: calendar, style: $style)
                NotificationSoundPicker(kind: calendar.kind, calendar: calendar, player: player)
            }
            if calendar.kind == .event {
                Section {
                    AllDayAlertTimeRow(calendar: calendar)
                }
            }
        }
        .formStyle(.grouped)
        .accessibilityIdentifier("CalendarNotificationDetail.\(calendar.title)")
    }
}
