import Planner
import SwiftUI

struct PermissionBanner: View {
    @Environment(PermissionCenter.self) private var center
    let kind: PermissionKind
    let onDismiss: () -> Void

    var body: some View {
        let status = center.status(of: kind) ?? .notDetermined
        HStack(spacing: 12) {
            Image(systemName: kind.systemImage)
                .foregroundStyle(.tint)
            Text(status.canRequest ? kind.requestTitle : kind.deniedTitle)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
            PermissionActionButton(
                kind: kind,
                status: status,
                requestTitle: String(localized: "Action.Allow", table: "Permissions")
            )
            .buttonStyle(.bordered)
            .controlSize(.small)
            Button(String(localized: "Action.Dismiss", table: "Permissions"), systemImage: "xmark", action: onDismiss)
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
        .accessibilityIdentifier("PermissionBanner.\(kind.rawValue)")
    }
}
