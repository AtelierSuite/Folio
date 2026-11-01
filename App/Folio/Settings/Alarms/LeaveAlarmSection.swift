import Planner
import SwiftUI

struct LeaveAlarmSection: View {
    @Environment(LeaveAlertCenter.self) private var leaveAlerts
    @Environment(NotificationScheduler.self) private var scheduler

    private var isAvailable: Bool {
        leaveAlerts.isSupported && leaveAlerts.isEnabled && scheduler.isEnabled
    }

    var body: some View {
        Section {
            LeaveAlarmRows()
                .disabled(!isAvailable)
        } header: {
            Text(String(localized: "Settings.Section", table: "LeaveAlerts"))
        } footer: {
            Text(String(localized: "Settings.AlarmFooter", table: "LeaveAlerts"))
        }
        .onAppear {
            leaveAlerts.refreshAuthorization()
        }
    }
}
