import Planner
import SwiftUI

struct CalendarNotificationSection: View {
    let calendar: PlannerCalendar
    let accountTitle: String
    let player: NotificationSoundPreviewPlayer
    let footer: String?

    var body: some View {
        Section {
            NotificationStyleCalendarRow(calendar: calendar)
            NotificationSoundPicker(kind: calendar.kind, calendar: calendar, player: player)
            if calendar.kind == .event {
                AllDayAlertTimeRow(calendar: calendar)
            }
        } header: {
            HStack(spacing: 6) {
                Image(systemName: calendar.kind.accountSymbolName)
                    .foregroundStyle(calendar.color.color)
                Text(calendar.title)
                Spacer()
                Text(accountTitle)
                    .foregroundStyle(.secondary)
            }
        } footer: {
            if let footer {
                Text(footer)
            }
        }
    }
}
