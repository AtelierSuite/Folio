import Planner
import SwiftUI

struct EventLeaveAlertSection: View {
    @Environment(LeaveAlertCenter.self) private var leaveAlerts
    @Environment(NotificationScheduler.self) private var scheduler
    @Binding var choice: EventLocationAlertChoice
    let reference: CalendarItemReference?
    let hasLocation: Bool

    var body: some View {
        Section {
            Toggle(String(localized: "Editor.Toggle", table: "LeaveAlerts"), isOn: $choice.isOn)
                .disabled(!leaveAlerts.isSupported || (!hasLocation && !choice.isOn))
                .accessibilityIdentifier("TimeToLeaveToggle")
        } footer: {
            Text(footer)
        }
        .onAppear {
            choice.load(for: reference, from: leaveAlerts)
        }
    }

    private var footer: String {
        if !leaveAlerts.isSupported {
            String(localized: "Unsupported", table: "LeaveAlerts")
        } else if !hasLocation {
            String(localized: "Editor.NoLocation", table: "LeaveAlerts")
        } else if choice.isOn && (!leaveAlerts.isEnabled || !scheduler.isEnabled) {
            String(localized: "Editor.TurnedOff", table: "LeaveAlerts")
        } else {
            String(localized: "Editor.Footer", table: "LeaveAlerts")
        }
    }
}
