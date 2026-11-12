import SwiftUI

struct PermissionPromptMessage: View {
    let message: String
    let isRestricted: Bool

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 4) {
                Text(message)
                if isRestricted {
                    Text(String(localized: "Restricted.Description", table: "Permissions"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        } icon: {
            SettingsIconTile(image: Image(systemName: "info"), color: .blue)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }
}
