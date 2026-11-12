import Planner
import SwiftUI

struct PermissionPromptSection: View {
    @Environment(PermissionCenter.self) private var center
    @Environment(\.openURL) private var openURL
    let kind: PermissionKind
    let message: String
    var asksOnToggle = false

    var body: some View {
        if let status = center.status(of: kind), isShown(for: status) {
            Section {
                PermissionPromptMessage(message: message, isRestricted: status == .restricted)
                if status.canRequest {
                    Button(String(localized: "Action.Continue", table: "Permissions")) {
                        Task { await center.request(kind) }
                    }
                    .accessibilityIdentifier("PermissionPrompt.\(kind.rawValue).Continue")
                } else if status.canBeFixedInSettings, let settingsURL = kind.appSettingsURL {
                    Button(String(localized: "Action.OpenSettings", table: "Permissions")) {
                        openURL(settingsURL)
                    }
                    .accessibilityIdentifier("PermissionPrompt.\(kind.rawValue).OpenSettings")
                }
            }
        }
    }

    private func isShown(for status: PermissionStatus) -> Bool {
        asksOnToggle ? status.isBlocked : status.isMissingAccess
    }
}

extension PermissionCenter {
    func isBlocked(_ kind: PermissionKind) -> Bool {
        status(of: kind)?.isBlocked ?? false
    }

    func allowsTurningOn(_ isOn: Bool, needing kind: PermissionKind) async -> Bool {
        guard isOn else { return true }
        let status = await request(kind)
        return status.allowsAccess || status == .unavailable
    }
}
