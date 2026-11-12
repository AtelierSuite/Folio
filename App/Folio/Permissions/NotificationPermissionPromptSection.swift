import Planner
import SwiftUI

struct NotificationPermissionPromptSection: View {
    @Environment(NotificationScheduler.self) private var scheduler
    var message = String(localized: "Prompt.Notifications", table: "Permissions")

    var body: some View {
        PermissionPromptSection(kind: .notifications, message: message) {
            await scheduler.setEnabled(true)
        }
    }
}
