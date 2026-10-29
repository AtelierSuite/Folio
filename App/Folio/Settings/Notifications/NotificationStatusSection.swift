import Planner
import SwiftUI

struct NotificationStatusSection: View {
    @Environment(NotificationScheduler.self) private var scheduler

    var body: some View {
        Section(String(localized: "Status.Section", table: "Notifications")) {
            LabeledContent(
                String(localized: "Status.Scheduled", table: "Notifications"),
                value: (scheduler.lastReport?.scheduledCount ?? 0).formatted()
            )
            .accessibilityIdentifier("NotificationsScheduledCount")
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
