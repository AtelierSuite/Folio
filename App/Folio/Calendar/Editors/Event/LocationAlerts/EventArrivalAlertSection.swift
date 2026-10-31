import Planner
import SwiftUI

struct EventArrivalAlertSection: View {
    @Environment(ArrivalAlertCenter.self) private var arrivalAlerts
    @Environment(NotificationScheduler.self) private var scheduler
    @Binding var choice: EventLocationAlertChoice
    let reference: CalendarItemReference?
    let hasLocation: Bool

    var body: some View {
        Section {
            Toggle(String(localized: "Editor.Toggle", table: "ArrivalAlerts"), isOn: $choice.isOn)
                .disabled(!arrivalAlerts.isSupported || (!hasLocation && !choice.isOn))
                .accessibilityIdentifier("NotifyOnArrivalToggle")
        } footer: {
            Text(footer)
        }
        .onAppear {
            choice.load(for: reference, from: arrivalAlerts)
        }
    }

    private var footer: String {
        if !arrivalAlerts.isSupported {
            String(localized: "Unsupported", table: "ArrivalAlerts")
        } else if !hasLocation {
            String(localized: "Editor.NoLocation", table: "ArrivalAlerts")
        } else if choice.isOn && (!arrivalAlerts.isEnabled || !scheduler.isEnabled) {
            String(localized: "Editor.TurnedOff", table: "ArrivalAlerts")
        } else {
            String(localized: "Editor.Footer", table: "ArrivalAlerts")
        }
    }
}
