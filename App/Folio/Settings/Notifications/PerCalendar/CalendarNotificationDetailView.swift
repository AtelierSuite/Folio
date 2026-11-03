import Planner
import SwiftUI

struct CalendarNotificationDetailView: View {
    @Environment(\.platformCapabilities) private var capabilities
    let calendar: PlannerCalendar
    let player: NotificationSoundPreviewPlayer
    @Binding var style: NotificationAlertStyle

    var body: some View {
        Form {
            Section {
                NotificationStyleCalendarRow(calendar: calendar, style: $style)
                NotificationSoundPicker(kind: calendar.kind, calendar: calendar, player: player)
                if calendar.kind == .event {
                    AllDayAlertTimeRow(calendar: calendar)
                }
            } footer: {
                Text(footer)
            }
        }
        .formStyle(.grouped)
        .accessibilityIdentifier("CalendarNotificationDetail.\(calendar.title)")
    }

    private var footer: String {
        let styleFooter = capabilities.supports(.alarms)
            ? String(localized: "Defaults.Footer.Alarms", table: "NotificationStyles")
            : String(localized: "Defaults.Footer", table: "NotificationStyles")
        guard calendar.kind == .event else { return styleFooter }
        return styleFooter + " " + String(localized: "AllDay.Footer", table: "Notifications")
    }
}
