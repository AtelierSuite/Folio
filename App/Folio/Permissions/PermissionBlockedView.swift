import Planner
import SwiftUI

struct PermissionBlockedView: View {
    @Environment(PermissionCenter.self) private var center
    let kind: PermissionKind
    let requestable: [PermissionKind]

    var body: some View {
        let status = center.status(of: kind) ?? .notDetermined
        ContentUnavailableView {
            Label(title(for: status), systemImage: kind.systemImage)
        } description: {
            Text(description(for: status))
        } actions: {
            VStack(spacing: 12) {
                PermissionActionButton(kind: kind, status: status)
                    .buttonStyle(.borderedProminent)
                ForEach(requestable) { other in
                    PermissionRequestButton(kind: other)
                        .buttonStyle(.bordered)
                }
            }
            .buttonSizing(.flexible)
            .controlSize(.large)
            .frame(maxWidth: 400)
        }
        .accessibilityIdentifier("PermissionBlocked.\(kind.rawValue)")
    }

    private func title(for status: PermissionStatus) -> String {
        status.canRequest ? kind.requestTitle : kind.deniedTitle
    }

    private func description(for status: PermissionStatus) -> String {
        switch status {
        case .restricted: String(localized: "Restricted.Description", table: "Permissions")
        case .denied: kind.deniedDescription
        default: kind.requestDescription
        }
    }
}
