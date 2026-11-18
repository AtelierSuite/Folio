import Planner
import SwiftUI

struct BirthdayAlertsSection: View {
    @Environment(NotificationScheduler.self) private var scheduler
    @State private var player = NotificationSoundPreviewPlayer()
    @State private var alertsOnTheDay = BirthdaySettings.shared.alertsOnTheDay
    @State private var alertsDayBefore = BirthdaySettings.shared.alertsDayBefore
    let calendar: PlannerCalendar?

    var body: some View {
        Section {
            Toggle(String(localized: "Alerts.OnTheDay", table: "Birthdays"), isOn: $alertsOnTheDay)
                .accessibilityIdentifier("BirthdayAlertsOnTheDayToggle")
            Toggle(String(localized: "Alerts.DayBefore", table: "Birthdays"), isOn: $alertsDayBefore)
                .accessibilityIdentifier("BirthdayAlertsDayBeforeToggle")
            if let calendar {
                CalendarNotificationRow(calendar: calendar, player: player)
            }
        } header: {
            Text(String(localized: "Alerts.Header", table: "Birthdays"))
        } footer: {
            Text(String(localized: "Alerts.Footer", table: "Birthdays"))
        }
        .disabled(!(scheduler.isEnabled && scheduler.includesEvents))
        .onChange(of: alertsOnTheDay) {
            BirthdaySettings.shared.alertsOnTheDay = alertsOnTheDay
            Task { await scheduler.replan() }
        }
        .onChange(of: alertsDayBefore) {
            BirthdaySettings.shared.alertsDayBefore = alertsDayBefore
            Task { await scheduler.replan() }
        }
        .onDisappear {
            player.stop()
        }
    }
}
