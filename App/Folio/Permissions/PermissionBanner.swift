import Planner
import SwiftUI

struct PermissionBanner: View {
    @Environment(PermissionCenter.self) private var center
    @Environment(\.openURL) private var openURL
    let kind: PermissionKind
    let onDismiss: () -> Void

    var body: some View {
        let status = center.status(of: kind) ?? .notDetermined
        HStack(spacing: 12) {
            Button {
                performAction(for: status)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: kind.systemImage)
                        .foregroundStyle(.tint)
                    Text(status.canRequest ? kind.requestTitle : kind.deniedTitle)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if hasAction(for: status) {
                        Image(systemName: "chevron.forward")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .disabled(!hasAction(for: status))
            .accessibilityHint(actionHint(for: status))
            .accessibilityIdentifier("PermissionBanner.\(kind.rawValue).Action")
            Button(String(localized: "Action.Dismiss", table: "Permissions"), systemImage: "xmark", action: onDismiss)
                .labelStyle(.iconOnly)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .controlSize(.regular)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
        .accessibilityIdentifier("PermissionBanner.\(kind.rawValue)")
    }

    private func hasAction(for status: PermissionStatus) -> Bool {
        status.canRequest || ((status.canBeFixedInSettings || status.mayHideMissingAccess) && kind.settingsURL != nil)
    }

    private func actionHint(for status: PermissionStatus) -> String {
        if status.canRequest {
            String(localized: "Action.Allow", table: "Permissions")
        } else if status.canBeFixedInSettings {
            String(localized: "Action.OpenSettings", table: "Permissions")
        } else if status.mayHideMissingAccess {
            String(localized: "Action.Manage", table: "Permissions")
        } else {
            ""
        }
    }

    private func performAction(for status: PermissionStatus) {
        if status.canRequest {
            Task {
                await center.request(kind)
            }
        } else if let url = kind.settingsURL {
            openURL(url)
        }
    }
}
