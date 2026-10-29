import Planner
import SwiftUI

struct NotificationStatusSection: View {
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(\.platformCapabilities) private var capabilities

    var body: some View {
        Section(String(localized: "Status.Section", table: "Notifications")) {
            LabeledContent(
                String(localized: "Status.Scheduled", table: "Notifications"),
                value: (scheduler.lastReport?.scheduledCount ?? 0).formatted()
            )
            .accessibilityIdentifier("NotificationsScheduledCount")
            if capabilities.supports(.alarms) {
                LabeledContent(
                    String(localized: "Status.Alarms", table: "NotificationStyles"),
                    value: (scheduler.lastReport?.alarmCount ?? 0).formatted()
                )
            }
            LabeledContent(String(localized: "Status.NextAlert", table: "Notifications"), value: nextAlert)
            Button(String(localized: "Status.Refresh", table: "Notifications")) {
                Task { await scheduler.replan() }
            }
        }
    }

    private var nextAlert: String {
        guard let nextFireDate = scheduler.lastReport?.nextFireDate else {
            return String(localized: "Status.None", table: "Notifications")
        }
        return nextFireDate.formatted(date: .abbreviated, time: .shortened)
    }
}
