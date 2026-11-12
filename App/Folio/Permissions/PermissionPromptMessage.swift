import SwiftUI

struct PermissionPromptMessage: View {
    let message: String
    let isRestricted: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            SettingsIconTile(image: Image(systemName: "info"), color: .blue, glyphScale: 0.45)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(message)
                if isRestricted {
                    Text(String(localized: "Restricted.Description", table: "Permissions"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}
