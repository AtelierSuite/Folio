import Planner
import SwiftUI

struct PermissionPromptSection: View {
    @Environment(PermissionCenter.self) private var center
    @Environment(\.openURL) private var openURL
    let kind: PermissionKind
    let message: String
    var onGrant: (@MainActor () async -> Void)?

    var body: some View {
        if let status = center.status(of: kind), status.isMissingAccess {
            Section {
                PermissionPromptMessage(message: message, isRestricted: status == .restricted)
                if status.canRequest {
                    Button(String(localized: "Action.Continue", table: "Permissions")) {
                        Task { await requestAccess() }
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

    private func requestAccess() async {
        guard await center.request(kind).allowsAccess else { return }
        await onGrant?()
    }
}

extension PermissionCenter {
    func isMissingAccess(to kind: PermissionKind) -> Bool {
        status(of: kind)?.isMissingAccess ?? false
    }
}
