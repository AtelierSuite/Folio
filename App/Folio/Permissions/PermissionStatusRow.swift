import Planner
import SwiftUI

struct PermissionStatusRow: View {
    @Environment(PermissionCenter.self) private var center
    let kind: PermissionKind

    var body: some View {
        let status = center.status(of: kind) ?? .notDetermined
        LabeledContent {
            HStack {
                Text(status.label)
                    .foregroundStyle(.secondary)
                PermissionActionButton(
                    kind: kind,
                    status: status,
                    requestTitle: String(localized: "Action.Allow", table: "Permissions")
                )
                .buttonStyle(.bordered)
            }
        } label: {
            Label(kind.name, systemImage: kind.systemImage)
        }
        .accessibilityIdentifier("PermissionStatus.\(kind.rawValue)")
    }
}
