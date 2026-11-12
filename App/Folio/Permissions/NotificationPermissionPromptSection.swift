import Planner
import SwiftUI

struct NotificationPermissionPromptSection: View {
    var message = String(localized: "Prompt.Notifications", table: "Permissions")

    var body: some View {
        PermissionPromptSection(kind: .notifications, message: message, asksOnToggle: true)
    }
}
