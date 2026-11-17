import Planner
import SwiftUI

/// Travel alerts are notifications, so the page asks for them first: the system permission if it's blocked,
/// otherwise Folio's own notifications switch.
struct TravelNotificationsPromptSection: View {
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(PermissionCenter.self) private var permissionCenter

    private var message: String {
        String(localized: "Travel.NotificationsOff", table: "Settings")
    }

    var body: some View {
        if permissionCenter.status(of: .notifications)?.isMissingAccess == true {
            PermissionPromptSection(kind: .notifications, message: message)
        } else if !scheduler.isEnabled {
            Section {
                PermissionPromptMessage(message: message, isRestricted: false)
                Button(String(localized: "Action.TurnOn", table: "Permissions")) {
                    Task {
                        await scheduler.setEnabled(true)
                        await permissionCenter.refresh(.notifications)
                    }
                }
                .accessibilityIdentifier("TravelNotificationsTurnOn")
            }
        }
    }
}
