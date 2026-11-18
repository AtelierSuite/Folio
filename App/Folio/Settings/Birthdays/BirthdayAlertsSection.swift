import Planner
import SwiftUI

struct BirthdayAlertsSection: View {
    @Environment(NotificationScheduler.self) private var scheduler
    @State private var player = NotificationSoundPreviewPlayer()
    let calendar: PlannerCalendar

    var body: some View {
        Section(String(localized: "Alerts.Header", table: "Birthdays")) {
            CalendarNotificationRow(calendar: calendar, player: player)
        }
        .disabled(!(scheduler.isEnabled && scheduler.includesEvents))
        .onDisappear {
            player.stop()
        }
    }
}
