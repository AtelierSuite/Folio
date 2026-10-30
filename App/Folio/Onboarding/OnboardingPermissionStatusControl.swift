import Planner
import SwiftUI

struct OnboardingPermissionStatusControl: View {
    let kind: PermissionKind
    let status: PermissionStatus

    var body: some View {
        if status.allowsAccess {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.green)
                .accessibilityLabel(status.label)
        } else if status == .restricted {
            Text(status.label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else {
            PermissionActionButton(
                kind: kind,
                status: status,
                requestTitle: String(localized: "Action.Allow", table: "Permissions")
            )
            .buttonStyle(.bordered)
            #if !os(macOS)
            .buttonBorderShape(.capsule)
            #endif
        }
    }
}
